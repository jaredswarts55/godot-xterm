// SPDX-FileCopyrightText: 2026 Jared Swarts
// SPDX-License-Identifier: MIT

// Built and run by .github/workflows/loci.yml (job "Unicode width table").

#include "wcwidth.h"

#include <stdint.h>
#include <stdio.h>

static int tests_run;
static int failures;

static void expect(int expected, uint32_t cp, const char* what) {
    tests_run++;
    int actual = tsm_wcwidth((wchar_t)cp);
    if (actual != expected) {
        fprintf(stderr, "FAIL: U+%04X %s: width %d, expected %d\n", cp, what, actual, expected);
        failures++;
    }
}

int main(void) {
    expect(0, 0x0000, "NUL");
    expect(-1, 0x001B, "ESC");
    expect(-1, 0x007F, "DEL");
    expect(-1, 0x009B, "CSI (C1)");
    expect(1, 'a', "LATIN SMALL LETTER A");
    expect(1, 0x00E9, "LATIN SMALL LETTER E WITH ACUTE");
    expect(1, 0x00AD, "SOFT HYPHEN");

    expect(0, 0x0301, "COMBINING ACUTE ACCENT");
    expect(0, 0x20DD, "COMBINING ENCLOSING CIRCLE");
    expect(0, 0x200B, "ZERO WIDTH SPACE");
    expect(0, 0x200D, "ZERO WIDTH JOINER");
    expect(0, 0xFE0F, "VARIATION SELECTOR-16");
    expect(0, 0x1160, "HANGUL JUNGSEONG FILLER");
    expect(0, 0x3099, "COMBINING KATAKANA-HIRAGANA VOICED SOUND MARK");
    expect(1, 0x0600, "ARABIC NUMBER SIGN");

    expect(2, 0x4E2D, "CJK UNIFIED IDEOGRAPH-4E2D");
    expect(2, 0x3042, "HIRAGANA LETTER A");
    expect(2, 0xAC00, "HANGUL SYLLABLE GA");
    expect(2, 0xFF21, "FULLWIDTH LATIN CAPITAL LETTER A");
    expect(2, 0x20000, "CJK UNIFIED IDEOGRAPH-20000");
    expect(2, 0x2FFFD, "unassigned, plane 2");
    expect(2, 0x3FFFD, "unassigned, plane 3");

    expect(2, 0x1F600, "GRINNING FACE");
    expect(2, 0x1F972, "SMILING FACE WITH TEAR (Unicode 13)");
    expect(2, 0x1FAE8, "SHAKING FACE (Unicode 15)");
    expect(2, 0x1FAE9, "FACE WITH BAGS UNDER EYES (Unicode 16)");
    expect(2, 0x231A, "WATCH");
    expect(2, 0x2705, "WHITE HEAVY CHECK MARK");
    expect(1, 0x2764, "HEAVY BLACK HEART (text presentation)");
    expect(1, 0x1F1E6, "REGIONAL INDICATOR SYMBOL LETTER A");

    expect(1, 0x2500, "BOX DRAWINGS LIGHT HORIZONTAL");
    expect(1, 0x256D, "BOX DRAWINGS LIGHT ARC DOWN AND RIGHT");
    expect(1, 0x2588, "FULL BLOCK");
    expect(1, 0x273B, "TEARDROP-SPOKED ASTERISK");
    expect(1, 0x23FA, "BLACK CIRCLE FOR RECORD");
    expect(1, 0x1FBF0, "SEGMENTED DIGIT ZERO");

    expect(1, 0xE0B0, "private use (Powerline)");
    expect(1, 0xF000, "private use (Nerd Fonts)");
    expect(1, 0xF0001, "supplementary private use");

    if (failures > 0) {
        printf("%d of %d tests FAILED\n", failures, tests_run);
        return 1;
    }
    printf("%d tests OK\n", tests_run);
    return 0;
}
