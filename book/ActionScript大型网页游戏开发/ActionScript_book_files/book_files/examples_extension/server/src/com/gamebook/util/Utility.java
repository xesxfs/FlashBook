package com.gamebook.util;

import com.electrotank.electroserver4.extensions.api.value.EsObject;
import com.electrotank.electroserver4.extensions.api.value.Number;

public class Utility {

    public static double getDoubleFromNumber(String name, EsObject obj) {
        Number num = obj.getNumber(name);
        return num.getValue();
    }
    
    public static double getDoubleFromNumber(String name, Number num) {
        return num.getValue();
    }
    public static long getLongFromNumber(String name, EsObject  obj) {
        Number num = obj.getNumber(name);
        double dub = num.getValue();
        return (long) dub;
    }
    
    public static long getLongFromNumber(String name, Number num) {
        double dub = num.getValue();
        return (long) dub;
    }
    
}
