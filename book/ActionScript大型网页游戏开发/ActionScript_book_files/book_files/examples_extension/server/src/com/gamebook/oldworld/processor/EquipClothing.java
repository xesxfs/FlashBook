package com.gamebook.oldworld.processor;

import com.electrotank.electroserver4.extensions.api.PluginApi;
import com.electrotank.electroserver4.extensions.api.value.EsObject;
import com.electrotank.electroserver4.extensions.api.value.EsObjectRO;
import com.gamebook.oldworld.Command;
import com.gamebook.oldworld.ErrorCode;
import com.gamebook.oldworld.ExtensionBoundField;
import com.gamebook.oldworld.Field;
import com.gamebook.oldworld.MessagingHelper;
import com.gamebook.oldworld.UserType;
import com.gamebook.oldworld.model.Avatar;
import com.gamebook.oldworld.model.ClothingItem;
import com.gamebook.oldworld.model.ClothingType;
import java.util.Map;
import org.skife.jdbi.v2.DBI;
import org.skife.jdbi.v2.Handle;
import org.skife.jdbi.v2.TransactionCallback;
import org.skife.jdbi.v2.TransactionStatus;

public class EquipClothing extends AbstractProcessor {

    public EquipClothing( DBI dbi ) {
        super( dbi );
    }

    @Override
    public String getCommand() {
        return Command.EquipClothing.getCode();
    }

    @Override
    public UserType getAllowedUserType() {
        return UserType.Player;
    }

    @Override
    public void process( final String user, final EsObjectRO message, final PluginApi api ) {

        // Look up their account in the database via the username/password
        boolean success = dbi.inTransaction( new TransactionCallback<Boolean>() {
            @Override
            public Boolean inTransaction( Handle handle, TransactionStatus status ) throws Exception {
                return equipClothing( handle, user, message, api );
            }
        } );

        if(success) {
            MessagingHelper.sendSuccessMessage(Command.EquipClothing, user, api);
        }

    }

    private boolean equipClothing(Handle handle, String user, EsObjectRO message, PluginApi api) {

        int clothingId = message.getInteger(Field.ClothingId.getCode());

        // Look up the clothing map
        @SuppressWarnings("unchecked")
        Map<Integer, ClothingItem> clothingMap = (Map<Integer, ClothingItem>) api.acquireManagedObject(ExtensionBoundField.ControllerFactory.toString(),
                    new EsObject(ExtensionBoundField.ObjectName.toString(), ExtensionBoundField.ClothingMap.toString()));

        // Get the specified piece of clothing
        ClothingItem clothing = clothingMap.get(clothingId);
        if(clothing == null) {
            MessagingHelper.sendErrorMessage(Command.EquipClothing, user, ErrorCode.ClothingIdDoesntExist, api);
            return false;
        }

        // Make sure the avatar actually owns a piece of this clothing
        Avatar avatar = (Avatar) api.getExtensionBoundUserServerVariable(user, ExtensionBoundField.Avatar.toString()).getValue();

        boolean hit = false;
        for(ClothingItem tempItem : avatar.getClothingInventory()) {
            if(tempItem.getId() == clothingId) {
                hit = true;
                break;
            }
        }

        if(!hit) {
            MessagingHelper.sendErrorMessage(Command.EquipClothing, user, ErrorCode.AvatarDoesntOwnSpecifiedClothing, api);
            return false;
        }

        // Get the type so we know what socket it goes into
        ClothingType type = clothing.getClothingType();

        String sqlFile = null;
        switch(type) {
            case Hair:
                avatar.setHair(clothing);
                sqlFile = "sql/UpdateAvatarHairstyle.sql";
                break;
            case Top:
                avatar.setTop(clothing);
                sqlFile = "sql/UpdateAvatarTop.sql";
                break;
            case Bottom:
                avatar.setBottom(clothing);
                sqlFile = "sql/UpdateAvatarBottom.sql";
                break;
            case Shoes:
                avatar.setShoes(clothing);
                sqlFile = "sql/UpdateAvatarShoes.sql";
                break;
        }

        // Create the query
        handle.createStatement( sqlFile )
            .bind("clothingId", clothingId )
            .bind("avatarId", avatar.getId())
            .execute();

        return true;
    }

}

