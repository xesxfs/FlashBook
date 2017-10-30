package com.gamebook.oldworld.model;

import com.electrotank.electroserver4.extensions.api.value.EsObject;
import com.gamebook.oldworld.Field;

public class FurnitureEntry {

    private int id;
    private FurnitureItem furniture;
    private int row;
    private int column;
    private boolean inWorld;

    public EsObject toEsObject() {

        EsObject out = new EsObject();

        out.setInteger(Field.FurnitureEntryId.getCode(), id);
        out.setInteger(Field.Row.getCode(), row);
        out.setInteger(Field.Column.getCode(), column);
        out.setBoolean(Field.InWorld.getCode(), inWorld);
        out.setEsObject(Field.FurnitureItem.getCode(), furniture.toEsObject());

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
     * @return the furniture
     */
    public FurnitureItem getFurniture() {
        return furniture;
    }

    /**
     * @param furniture the furniture to set
     */
    public void setFurniture(FurnitureItem furniture) {
        this.furniture = furniture;
    }

    /**
     * @return the row
     */
    public int getRow() {
        return row;
    }

    /**
     * @param row the row to set
     */
    public void setRow(int row) {
        this.row = row;
    }

    /**
     * @return the column
     */
    public int getColumn() {
        return column;
    }

    /**
     * @param column the column to set
     */
    public void setColumn(int column) {
        this.column = column;
    }

    /**
     * @return the inWorld
     */
    public boolean isInWorld() {
        return inWorld;
    }

    /**
     * @param inWorld the inWorld to set
     */
    public void setInWorld(boolean inWorld) {
        this.inWorld = inWorld;
    }

}
