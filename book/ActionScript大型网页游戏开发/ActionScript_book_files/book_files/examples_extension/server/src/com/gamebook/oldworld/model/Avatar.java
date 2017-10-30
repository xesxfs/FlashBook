package com.gamebook.oldworld.model;

import com.electrotank.electroserver4.extensions.api.value.EsObject;
import com.gamebook.oldworld.Field;
import java.util.List;

public class Avatar {

    private int id;
    private String name;
    private String password;
    private Gender gender;
    private ClothingItem hair;
    private ClothingItem top;
    private ClothingItem bottom;
    private ClothingItem shoes;
    private List<ClothingItem> clothingInventory;
    private int money;

    public EsObject toEsObject(boolean includePrivateInfo) {

        EsObject out = new EsObject();

        out.setInteger(Field.AvatarId.getCode(), id);
        out.setString(Field.AvatarName.getCode(), name);
        out.setString(Field.AvatarGender.getCode(), gender.getCharacterCode());
        out.setInteger(Field.AvatarHair.getCode(), hair.getId());
        out.setInteger(Field.AvatarTop.getCode(), top.getId());
        out.setInteger(Field.AvatarBottom.getCode(), bottom.getId());
        out.setInteger(Field.AvatarShoes.getCode(), shoes.getId());

        // If we are loading the info for ourselves, we can include things that are not public knowledge
        if(includePrivateInfo) {
            out.setInteger(Field.AvatarMoney.getCode(), money);
            int[] idArray = new int[clothingInventory.size()];
            for(int i = 0; i < clothingInventory.size(); i++) {
                idArray[i] = clothingInventory.get(i).getId();
            }
            out.setIntegerArray(Field.AvatarClothing.getCode(), idArray);
        }


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
     * @return the password
     */
    public String getPassword() {
        return password;
    }

    /**
     * @param password the password to set
     */
    public void setPassword(String password) {
        this.password = password;
    }

    /**
     * @return the gender
     */
    public Gender getGender() {
        return gender;
    }

    /**
     * @param gender the gender to set
     */
    public void setGender(Gender gender) {
        this.gender = gender;
    }

    /**
     * @return the hair
     */
    public ClothingItem getHair() {
        return hair;
    }

    /**
     * @param hair the hair to set
     */
    public void setHair(ClothingItem hair) {
        this.hair = hair;
    }

    /**
     * @return the top
     */
    public ClothingItem getTop() {
        return top;
    }

    /**
     * @param top the top to set
     */
    public void setTop(ClothingItem top) {
        this.top = top;
    }

    /**
     * @return the bottom
     */
    public ClothingItem getBottom() {
        return bottom;
    }

    /**
     * @param bottom the bottom to set
     */
    public void setBottom(ClothingItem bottom) {
        this.bottom = bottom;
    }

    /**
     * @return the shoes
     */
    public ClothingItem getShoes() {
        return shoes;
    }

    /**
     * @param shoes the shoes to set
     */
    public void setShoes(ClothingItem shoes) {
        this.shoes = shoes;
    }

    /**
     * @return the clothingInventory
     */
    public List<ClothingItem> getClothingInventory() {
        return clothingInventory;
    }

    /**
     * @param clothingInventory the clothingInventory to set
     */
    public void setClothingInventory(List<ClothingItem> clothingInventory) {
        this.clothingInventory = clothingInventory;
    }

    /**
     * @return the money
     */
    public int getMoney() {
        return money;
    }

    /**
     * @param money the money to set
     */
    public void setMoney(int money) {
        this.money = money;
    }

}
