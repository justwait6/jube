package com.jujube.core;

import android.graphics.Paint;
import android.graphics.Typeface;
import android.text.TextUtils;

public class Function {
    public static String getFixedWidthText(String font, int size, String text, int width) {
        if(text == null || text.length() < 3) {
            return text;
        }
        Paint p = new Paint();
        p.setTextSize(size);
        if(!TextUtils.isEmpty(font)){
            p.setTypeface(Typeface.create(font, Typeface.NORMAL));
        } else {
            p.setTypeface(Typeface.DEFAULT);
        }
        StringBuilder sb = new StringBuilder(text.substring(0, 1));
        sb.append("..");
        int i;
        String ret = "";
        for (i = 1; i < text.length(); i++) {
            float w = p.measureText(sb.toString());
            if(w < width){
                ret = sb.toString();
                sb.insert(i, text.subSequence(i, i + 1));
                if(i + 1 == text.length()) {
                    return text;
                }
            } else {
                break;
            }
        }
        return ret;
    }
}
