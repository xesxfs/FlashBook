package com.gamebook.oldworld.model;

import java.util.HashMap;
import java.util.Map;

public enum Gender {

    Male("M"),
    Female("F");

    private static Map<String, Gender> genderMap;

    private String characterCode;

    private Gender(String code) {
        characterCode = code;
        addToMap(this);
    }

    private static void addToMap(Gender gender) {
        if(genderMap == null) {
            genderMap = new HashMap<String, Gender>();
        }
        genderMap.put(gender.getCharacterCode(), gender);
    }

    public String getCharacterCode() {
        return characterCode;
    }

    public static Gender findByCharacterCode(String code) {
        return genderMap.get(code);
    }
}
