unsigned lodepng_encode(unsigned char** out, size_t* outsize,
                        const unsigned char* image, unsigned w, unsigned h,
                        LodePNGState* state) {
  unsigned char* data = 0; /*uncompressed version of the IDAT chunk data*/
  size_t datasize = 0;
  ucvector outv = ucvector_init(NULL, 0);
  LodePNGInfo info;
  const LodePNGInfo* info_png = &state->info_png;
  LodePNGColorMode auto_color;

  lodepng_info_init(&info);
  lodepng_color_mode_init(&auto_color);

  /*provide some proper output values if error will happen*/
  *out = 0;
  *outsize = 0;
  state->error = 0;

  /*check input values validity*/
  if((info_png->color.colortype == LCT_PALETTE || state->encoder.force_palette)
      && (info_png->color.palettesize == 0 || info_png->color.palettesize > 256)) {
    /*this error is returned even if auto_convert is enabled and thus encoder could
    generate the palette by itself: while allowing this could be possible in theory,
    it may complicate the code or edge cases, and always requiring to give a palette
    when setting this color type is a simpler contract*/
    state->error = 68; /*invalid palette size, it is only allowed to be 1-256*/
    goto cleanup;
  }
  if(state->encoder.zlibsettings.btype > 2) {
    state->error = 61; /*error: invalid btype*/
    goto cleanup;
  }
  if(info_png->interlace_method > 1) {
    state->error = 71; /*error: invalid interlace mode*/
    goto cleanup;
  }
  state->error = checkColorValidity(info_png->color.colortype, info_png->color.bitdepth);
  if(state->error) goto cleanup; /*error: invalid color type given*/
  state->error = checkColorValidity(state->info_raw.colortype, state->info_raw.bitdepth);
  if(state->error) goto cleanup; /*error: invalid color type given*/

  /* color convert and compute scanline filter types */
  lodepng_info_copy(&info, &state->info_png);
  if(state->encoder.auto_convert) {
    LodePNGColorStats stats;
    unsigned allow_convert = 1;
    lodepng_color_stats_init(&stats);
#ifdef LODEPNG_COMPILE_ANCILLARY_CHUNKS
    if(info_png->iccp_defined &&
        isGrayICCProfile(info_png->iccp_profile, info_png->iccp_profile_size)) {
      /*the PNG specification does not allow to use palette with a GRAY ICC profile, even
      if the palette has only gray colors, so disallow it.*/
      stats.allow_palette = 0;
    }
    if(info_png->iccp_defined &&
        isRGBICCProfile(info_png->iccp_profile, info_png->iccp_profile_size)) {
      /*the PNG specification does not allow to use grayscale color with RGB ICC profile, so disallow gray.*/
      stats.allow_greyscale = 0;
    }
#endif /* LODEPNG_COMPILE_ANCILLARY_CHUNKS */
    state->error = lodepng_compute_color_stats(&stats, image, w, h, &state->info_raw);
    if(state->error) goto cleanup;
#ifdef LODEPNG_COMPILE_ANCILLARY_CHUNKS
    if(info_png->background_defined) {
      /*the background chunk's color must be taken into account as well*/
      unsigned r = 0, g = 0, b = 0;
      LodePNGColorMode mode16 = lodepng_color_mode_make(LCT_RGB, 16);
      lodepng_convert_rgb(&r, &g, &b,
          info_png->background_r, info_png->background_g, info_png->background_b, &mode16, &info_png->color);
      state->error = lodepng_color_stats_add(&stats, r, g, b, 65535);
      if(state->error) goto cleanup;
    }
#endif /* LODEPNG_COMPILE_ANCILLARY_CHUNKS */
    state->error = auto_choose_color(&auto_color, &state->info_raw, &stats);
    if(state->error) goto cleanup;
#ifdef LODEPNG_COMPILE_ANCILLARY_CHUNKS
    if(info_png->sbit_defined) {
      /*if sbit is defined, due to strict requirements of which sbit values can be present for which color modes,
      auto_convert can't be done in many cases. However, do support a few cases here.
      TODO: more conversions may be possible, and it may also be possible to get a more appropriate color type out of
            auto_choose_color if knowledge about sbit is used beforehand
      */
      unsigned sbit_max = LODEPNG_MAX(LODEPNG_MAX(LODEPNG_MAX(info_png->sbit_r, info_png->sbit_g),
                           info_png->sbit_b), info_png->sbit_a);
      unsigned equal = (!info_png->sbit_g || info_png->sbit_g == info_png->sbit_r)
                    && (!info_png->sbit_b || info_png->sbit_b == info_png->sbit_r)
                    && (!info_png->sbit_a || info_png->sbit_a == info_png->sbit_r);
      allow_convert = 0;
      if(info.color.colortype == LCT_PALETTE &&
         auto_color.colortype == LCT_PALETTE) {
        /* input and output are palette, and in this case it may happen that palette data is
        expected to be copied from info_raw into the info_png */
        allow_convert = 1;
      }
      /*going from 8-bit RGB to palette (or 16-bit as long as sbit_max <= 8) is possible
      since both are 8-bit RGB for sBIT's purposes*/
      if(info.color.colortype == LCT_RGB &&
         auto_color.colortype == LCT_PALETTE && sbit_max <= 8) {
        allow_convert = 1;
      }
      /*going from 8-bit RGBA to palette is also ok but only if sbit_a is exactly 8*/
      if(info.color.colortype == LCT_RGBA && auto_color.colortype == LCT_PALETTE &&
         info_png->sbit_a == 8 && sbit_max <= 8) {
        allow_convert = 1;
      }
      /*going from 16-bit RGB(A) to 8-bit RGB(A) is ok if all sbit values are <= 8*/
      if((info.color.colortype == LCT_RGB || info.color.colortype == LCT_RGBA) && info.color.bitdepth == 16 &&
         auto_color.colortype == info.color.colortype && auto_color.bitdepth == 8 &&
         sbit_max <= 8) {
        allow_convert = 1;
      }
      /*going to less channels is ok if all bit values are equal (all possible values in sbit,
        as well as the chosen bitdepth of the result). Due to how auto_convert works,
        we already know that auto_color.colortype has less than or equal amount of channels than
        info.colortype. Palette is not used here. This conversion is not allowed if
        info_png->sbit_r < auto_color.bitdepth, because specifically for alpha, non-presence of
        an sbit value heavily implies that alpha's bit depth is equal to the PNG bit depth (rather
        than the bit depths set in the r, g and b sbit values, by how the PNG specification describes
        handling tRNS chunk case with sBIT), so be conservative here about ignoring user input.*/
      if(info.color.colortype != LCT_PALETTE && auto_color.colortype != LCT_PALETTE &&
         equal && info_png->sbit_r == auto_color.bitdepth) {
        allow_convert = 1;
      }
    }
#endif
    if(state->encoder.force_palette) {
      if(info.color.colortype != LCT_GREY && info.color.colortype != LCT_GREY_ALPHA &&
         (auto_color.colortype == LCT_GREY || auto_color.colortype == LCT_GREY_ALPHA)) {
        /*user speficially forced a PLTE palette, so cannot convert to grayscale types because
        the PNG specification only allows writing a suggested palette in PLTE for truecolor types*/
        allow_convert = 0;
      }
    }
    if(allow_convert) {
      lodepng_color_mode_copy(&info.color, &auto_color);
#ifdef LODEPNG_COMPILE_ANCILLARY_CHUNKS
      /*also convert the background chunk*/
      if(info_png->background_defined) {
        if(lodepng_convert_rgb(&info.background_r, &info.background_g, &info.background_b,
            info_png->background_r, info_png->background_g, info_png->background_b, &info.color, &info_png->color)) {
          state->error = 104;
          goto cleanup;
        }
      }
#endif /* LODEPNG_COMPILE_ANCILLARY_CHUNKS */
    }
  }
#ifdef LODEPNG_COMPILE_ANCILLARY_CHUNKS
  if(info_png->iccp_defined) {
    unsigned gray_icc = isGrayICCProfile(info_png->iccp_profile, info_png->iccp_profile_size);
    unsigned rgb_icc = isRGBICCProfile(info_png->iccp_profile, info_png->iccp_profile_size);
    unsigned gray_png = info.color.colortype == LCT_GREY || info.color.colortype == LCT_GREY_ALPHA;
    if(!gray_icc && !rgb_icc) {
      state->error = 100; /* Disallowed profile color type for PNG */
      goto cleanup;
    }
    if(gray_icc != gray_png) {
      /*Not allowed to use RGB/RGBA/palette with GRAY ICC profile or vice versa,
      or in case of auto_convert, it wasn't possible to find appropriate model*/
      state->error = state->encoder.auto_convert ? 102 : 101;
      goto cleanup;
    }
  }
#endif /*LODEPNG_COMPILE_ANCILLARY_CHUNKS*/
  if(!lodepng_color_mode_equal(&state->info_raw, &info.color)) {
    unsigned char* converted;
    size_t size = ((size_t)w * (size_t)h * (size_t)lodepng_get_bpp(&info.color) + 7u) / 8u;

    converted = (unsigned char*)lodepng_malloc(size);
    if(!converted && size) state->error = 83; /*alloc fail*/
    if(!state->error) {
      state->error = lodepng_convert(converted, image, &info.color, &state->info_raw, w, h);
    }
    if(!state->error) {
      state->error = preProcessScanlines(&data, &datasize, converted, w, h, &info, &state->encoder);
    }
    lodepng_free(converted);
    if(state->error) goto cleanup;
  } else {
    state->error = preProcessScanlines(&data, &datasize, image, w, h, &info, &state->encoder);
    if(state->error) goto cleanup;
  }

  /* output all PNG chunks */ {
#ifdef LODEPNG_COMPILE_ANCILLARY_CHUNKS
    size_t i;
#endif /*LODEPNG_COMPILE_ANCILLARY_CHUNKS*/
    /*write signature and chunks*/
    state->error = writeSignature(&outv);
    if(state->error) goto cleanup;
    /*IHDR*/
    state->error = addChunk_IHDR(&outv, w, h, info.color.colortype, info.color.bitdepth, info.interlace_method);
    if(state->error) goto cleanup;
#ifdef LODEPNG_COMPILE_ANCILLARY_CHUNKS
    /*unknown chunks between IHDR and PLTE*/
    if(info.unknown_chunks_data[0]) {
      state->error = addUnknownChunks(&outv, info.unknown_chunks_data[0], info.unknown_chunks_size[0]);
      if(state->error) goto cleanup;
    }
    /*color profile chunks must come before PLTE */
    if(info.iccp_defined) {
      state->error = addChunk_iCCP(&outv, &info, &state->encoder.zlibsettings);
      if(state->error) goto cleanup;
    }
    if(info.srgb_defined) {
      state->error = addChunk_sRGB(&outv, &info);
      if(state->error) goto cleanup;
    }
    if(info.gama_defined) {
      state->error = addChunk_gAMA(&outv, &info);
      if(state->error) goto cleanup;
    }
    if(info.chrm_defined) {
      state->error = addChunk_cHRM(&outv, &info);
      if(state->error) goto cleanup;
    }
    if(info_png->sbit_defined) {
      state->error = addChunk_sBIT(&outv, &info);
      if(state->error) goto cleanup;
    }
#endif /*LODEPNG_COMPILE_ANCILLARY_CHUNKS*/
    /*PLTE*/
    if(info.color.colortype == LCT_PALETTE) {
      state->error = addChunk_PLTE(&outv, &info.color);
      if(state->error) goto cleanup;
    }
    if(state->encoder.force_palette && (info.color.colortype == LCT_RGB || info.color.colortype == LCT_RGBA)) {
      /*force_palette means: write suggested palette for truecolor in PLTE chunk*/
      state->error = addChunk_PLTE(&outv, &info.color);
      if(state->error) goto cleanup;
    }
    /*tRNS (this will only add if when necessary) */
    state->error = addChunk_tRNS(&outv, &info.color);
    if(state->error) goto cleanup;
#ifdef LODEPNG_COMPILE_ANCILLARY_CHUNKS
    /*bKGD (must come between PLTE and the IDAt chunks*/
    if(info.background_defined) {
      state->error = addChunk_bKGD(&outv, &info);
      if(state->error) goto cleanup;
    }
    /*pHYs (must come before the IDAT chunks)*/
    if(info.phys_defined) {
      state->error = addChunk_pHYs(&outv, &info);
      if(state->error) goto cleanup;
    }

    /*unknown chunks between PLTE and IDAT*/
    if(info.unknown_chunks_data[1]) {
      state->error = addUnknownChunks(&outv, info.unknown_chunks_data[1], info.unknown_chunks_size[1]);
      if(state->error) goto cleanup;
    }
#endif /*LODEPNG_COMPILE_ANCILLARY_CHUNKS*/
    /*IDAT (multiple IDAT chunks must be consecutive)*/
    state->error = addChunk_IDAT(&outv, data, datasize, &state->encoder.zlibsettings);
    if(state->error) goto cleanup;
#ifdef LODEPNG_COMPILE_ANCILLARY_CHUNKS
    /*tIME*/
    if(info.time_defined) {
      state->error = addChunk_tIME(&outv, &info.time);
      if(state->error) goto cleanup;
    }
    /*tEXt and/or zTXt*/
    for(i = 0; i != info.text_num; ++i) {
      if(lodepng_strlen(info.text_keys[i]) > 79) {
        state->error = 66; /*text chunk too large*/
        goto cleanup;
      }
      if(lodepng_strlen(info.text_keys[i]) < 1) {
        state->error = 67; /*text chunk too small*/
        goto cleanup;
      }
      if(state->encoder.text_compression) {
        state->error = addChunk_zTXt(&outv, info.text_keys[i], info.text_strings[i], &state->encoder.zlibsettings);
        if(state->error) goto cleanup;
      } else {
        state->error = addChunk_tEXt(&outv, info.text_keys[i], info.text_strings[i]);
        if(state->error) goto cleanup;
      }
    }
    /*LodePNG version id in text chunk*/
    if(state->encoder.add_id) {
      unsigned already_added_id_text = 0;
      for(i = 0; i != info.text_num; ++i) {
        const char* k = info.text_keys[i];
        /* Could use strcmp, but we're not calling or reimplementing this C library function for this use only */
        if(k[0] == 'L' && k[1] == 'o' && k[2] == 'd' && k[3] == 'e' &&
           k[4] == 'P' && k[5] == 'N' && k[6] == 'G' && k[7] == '\0') {
          already_added_id_text = 1;
          break;
        }
      }
      if(already_added_id_text == 0) {
        state->error = addChunk_tEXt(&outv, "LodePNG", LODEPNG_VERSION_STRING); /*it's shorter as tEXt than as zTXt chunk*/
        if(state->error) goto cleanup;
      }
    }
    /*iTXt*/
    for(i = 0; i != info.itext_num; ++i) {
      if(lodepng_strlen(info.itext_keys[i]) > 79) {
        state->error = 66; /*text chunk too large*/
        goto cleanup;
      }
      if(lodepng_strlen(info.itext_keys[i]) < 1) {
        state->error = 67; /*text chunk too small*/
        goto cleanup;
      }
      state->error = addChunk_iTXt(
          &outv, state->encoder.text_compression,
          info.itext_keys[i], info.itext_langtags[i], info.itext_transkeys[i], info.itext_strings[i],
          &state->encoder.zlibsettings);
      if(state->error) goto cleanup;
    }

    /*unknown chunks between IDAT and IEND*/
    if(info.unknown_chunks_data[2]) {
      state->error = addUnknownChunks(&outv, info.unknown_chunks_data[2], info.unknown_chunks_size[2]);
      if(state->error) goto cleanup;
    }
#endif /*LODEPNG_COMPILE_ANCILLARY_CHUNKS*/
    state->error = addChunk_IEND(&outv);
    if(state->error) goto cleanup;
  }

cleanup:
  lodepng_info_cleanup(&info);
  lodepng_free(data);
  lodepng_color_mode_cleanup(&auto_color);

  /*instead of cleaning the vector up, give it to the output*/
  *out = outv.data;
  *outsize = outv.size;

  return state->error;
}