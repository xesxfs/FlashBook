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
import com.gamebook.oldworld.model.FurnitureItem;
import java.util.Map;
import org.skife.jdbi.v2.DBI;
import org.skife.jdbi.v2.Handle;
import org.skife.jdbi.v2.TransactionCallback;
import org.skife.jdbi.v2.TransactionStatus;

public class BuyItem extends AbstractProcessor {

    public BuyItem( DBI dbi ) {
        super( dbi );
    }

    @Override
    public String getCommand() {
        return Command.BuyItem.getCode();
    }

    @Override
    public UserType getAllowedUserType() {
        return UserType.Player;
    }

    @Override
    public void process( final String user, final EsObjectRO message, final PluginApi api ) {

        // Try and buy the item
        boolean success = dbi.inTransaction( new TransactionCallback<Boolean>() {
            @Override
            public Boolean inTransaction( Handle handle, TransactionStatus status ) throws Exception {
                return buyItem( handle, user, message, api );
            }
        } );

        if(success) {
            MessagingHelper.sendSuccessMessage(Command.BuyItem, user, api);
        }

    }

    private boolean buyItem(Handle handle, String user, EsObjectRO message, PluginApi api) {

        boolean clothing = false;
        if(message.getString(Field.ItemType.getCode()).equalsIgnoreCase("C")) {
            clothing = true;
        }
        int itemId = message.getInteger(Field.ItemId.getCode());

        // Make sure the avatar actually owns a piece of this clothing
        Avatar avatar = (Avatar) api.getExtensionBoundUserServerVariable(user, ExtensionBoundField.Avatar.toString()).getValue();

        // Look up the clothing map
        @SuppressWarnings("unchecked")
        Map<Integer, ClothingItem> clothingMap = (Map<Integer, ClothingItem>) api.acquireManagedObject(ExtensionBoundField.ControllerFactory.toString(),
                    new EsObject(ExtensionBoundField.ObjectName.toString(), ExtensionBoundField.ClothingMap.toString()));

        // Look up the furniture map
        @SuppressWarnings("unchecked")
        Map<Integer, FurnitureItem> furnitureMap = (Map<Integer, FurnitureItem>) api.acquireManagedObject(ExtensionBoundField.ControllerFactory.toString(),
                    new EsObject(ExtensionBoundField.ObjectName.toString(), ExtensionBoundField.FurnitureMap.toString()));

        // See if the item id exists in either map
        int cost = -1;
        if(!clothingMap.containsKey(itemId)) {
            cost = clothingMap.get(itemId).getCost();
            MessagingHelper.sendErrorMessage(Command.BuyItem, user, ErrorCode.ClothingIdDoesntExist, api);
            return false;
        }

        if(!furnitureMap.containsKey(itemId)) {
            cost = furnitureMap.get(itemId).getCost();
            MessagingHelper.sendErrorMessage(Command.BuyItem, user, ErrorCode.FurnitureIdDoesntExist, api);
            return false;
        }

        // Deduct the price from the avatar, validating they can afford it
        int money = avatar.getMoney();
        if(money < cost) {
            MessagingHelper.sendErrorMessage(Command.BuyItem, user, ErrorCode.AvatarCantAffordItem, api);
            return false;
        }

        money -= cost;
        avatar.setMoney(money);
        handle.createStatement( "sql/UpdateAvatarMoney.sql" )
                .bind("money", money )
                .bind("avatarId", avatar.getId())
                .execute();

        // Create and execute the appropriate query
        if(clothing) {
            handle.createStatement( "sql/InsertAvatarClothing.sql" )
                .bind("clothingId", itemId )
                .bind("avatarId", avatar.getId())
                .execute();
        } else {
            handle.createStatement( "sql/InsertAvatarFurniture.sql" )
                .bind("furnitureId", itemId )
                .bind("avatarId", avatar.getId())
                .bind("rowPosition", -1 )
                .bind("columnPosition", -1 )
                .bind("inWorld", false )
                .execute();
        }

        return true;
    }


}

