package com.gamebook.oldworld.model;

import com.electrotank.electroserver4.extensions.api.value.EsObject;
import com.gamebook.oldworld.Field;

public class ClothingItem {

    private int id;
    private ClothingType clothingType;
    private String name;
    private String fileName;
    private int cost;

    public EsObject toEsObject() {

        EsObject out = new EsObject();

        out.setInteger(Field.ClothingId.getCode(), id);
        out.setString(Field.ClothingName.getCode(), name);
        out.setString(Field.ClothingFileName.getCode(), fileName);
        out.setInteger(Field.ClothingCost.getCode(), cost);
        out.setInteger(Field.ClothingType.getCode(), clothingType.getTypeId());

        return out;
    }

    /**
     * @return the id
     */
    public int getId() {
        return id;
    }

    /**
     * @param id the id to set
     */
    public void setId(int id) {
        this.id = id;
    }

    /**
     * @return the clothingType
     */
    public ClothingType getClothingType() {
        return clothingType;
    }

    /**
     * @param clothingType the clothingType to set
     */
    public void setClothingType(ClothingType clothingType) {
        this.clothingType = clothingType;
    }

    /**
     * @return the name
     */
    public String getName() {
        return name;
    }

    /**
     * @param name the name to set
     */
    public void setName(String name) {
        this.name = name;
    }

    /**
     * @return the fileName
     */
    public String getFileName() {
        return fileName;
    }

    /**
     * @param fileName the fileName to set
     */
    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    /**
     * @return the cost
     */
    public int getCost() {
        return cost;
    }

    /**
     * @param cost the cost to set
     */
    public void setCost(int cost) {
        this.cost = cost;
    }

}
