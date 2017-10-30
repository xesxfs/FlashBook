package com.gamebook.oldworld.model;

import com.electrotank.electroserver4.extensions.api.value.EsObject;
import com.gamebook.oldworld.Field;

public class FurnitureItem {

    private int id;
    private String name;
    private String fileName;
    private int cost;

    public EsObject toEsObject() {

        EsObject out = new EsObject();

        out.setInteger(Field.FurnitureId.getCode(), id);
        out.setString(Field.FurnitureName.getCode(), name);
        out.setString(Field.FurnitureFileName.getCode(), fileName);
        out.setInteger(Field.FurnitureCost.getCode(), cost);

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
