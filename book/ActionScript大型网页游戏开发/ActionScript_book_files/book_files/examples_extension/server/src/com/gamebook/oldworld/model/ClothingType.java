package com.gamebook.oldworld.model;

import com.electrotank.electroserver4.extensions.api.value.EsObject;
import com.gamebook.oldworld.Field;
import java.util.HashMap;
import java.util.Map;

public enum ClothingType {

    Hair(1),
    Top(2),
    Bottom(3),
    Shoes(4);

    private static Map<Integer, ClothingType> typeMap;

    private int typeId;

    private ClothingType(int id) {
        typeId = id;
        addToMap(this);
    }

    private static void addToMap(ClothingType type) {
        if(typeMap == null) {
            typeMap = new HashMap<Integer, ClothingType>();
        }
        
        typeMap.put(type.getTypeId(), type);
    }

    public int getTypeId() {
        return typeId;
    }

    public EsObject toEsObject() {

        EsObject results = new EsObject();
        results.setInteger(Field.ClothingTypeId.getCode(), typeId);
        results.setString(Field.ClothingTypeName.getCode(), toString());
        return results;
    }

    public static ClothingType findById(int id) {
        return typeMap.get(id);
    }

    public static EsObject[] toEsObjectArray() {

        ClothingType[] allTypes = values();

        EsObject[] results = new EsObject[allTypes.length];

        for(int i = 0; i < allTypes.length; i++) {
            results[i] = allTypes[i].toEsObject();
        }

        return results;
    }
}
