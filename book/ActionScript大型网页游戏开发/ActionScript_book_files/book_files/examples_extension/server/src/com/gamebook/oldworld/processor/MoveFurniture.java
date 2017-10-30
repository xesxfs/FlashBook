package com.gamebook.oldworld.processor;

import com.electrotank.electroserver4.extensions.api.PluginApi;
import com.electrotank.electroserver4.extensions.api.value.EsObject;
import com.electrotank.electroserver4.extensions.api.value.EsObjectRO;
import com.gamebook.oldworld.AreaPlugin;
import com.gamebook.oldworld.Command;
import com.gamebook.oldworld.ErrorCode;
import com.gamebook.oldworld.Field;
import com.gamebook.oldworld.MessagingHelper;
import com.gamebook.oldworld.UserType;
import com.gamebook.oldworld.model.FurnitureEntry;
import java.util.Map;
import org.skife.jdbi.v2.DBI;
import org.skife.jdbi.v2.Handle;
import org.skife.jdbi.v2.TransactionCallback;
import org.skife.jdbi.v2.TransactionStatus;

public class MoveFurniture extends AbstractProcessor {

    public MoveFurniture( DBI dbi ) {
        super( dbi );
    }

    @Override
    public String getCommand() {
        return Command.MoveFurniture.getCode();
    }

    @Override
    public UserType getAllowedUserType() {
        return UserType.Player;
    }

    @Override
    public void process( final String user, final EsObjectRO message, final PluginApi api ) {

        // Try and load the furniture
        dbi.inTransaction( new TransactionCallback<Object>() {
            @Override
            public Object inTransaction( Handle handle, TransactionStatus status ) throws Exception {
                return moveFurniture( handle, user, message, api );
            }
        } );

    }

    private Object moveFurniture(Handle handle, String user, EsObjectRO message, PluginApi api) {

        // Get the data from the request
        int entryId = message.getInteger(Field.FurnitureEntryId.getCode());
        int row = message.getInteger(Field.Row.getCode());
        int column = message.getInteger(Field.Column.getCode());
        boolean inWorld = message.getBoolean(Field.InWorld.getCode());

        // Get the plugin and validate permissions
        AreaPlugin plugin = (AreaPlugin) api.getRoomPlugin(api.getZoneId(), api.getRoomId(), "AreaPlugin");
        if(!plugin.isOwned()) {
            MessagingHelper.sendErrorMessage(Command.MoveFurniture, user, ErrorCode.CanOnlyMoveFurnitureInARoom, api);
            return null;
        }
        if(!plugin.getOwnerName().equals(user)) {
            MessagingHelper.sendErrorMessage(Command.MoveFurniture, user, ErrorCode.CanOnlyMoveYourOwnFurniture, api);
            return null;
        }

        // Get the map of furniture for the room
        Map<Integer, FurnitureEntry> furnitureMap = plugin.getFurnitureEntryMap();

        // Get the entry specified from the map and fail if we can't find it
        FurnitureEntry entry = furnitureMap.get(entryId);
        if(entry == null) {
            MessagingHelper.sendErrorMessage(Command.MoveFurniture, user, ErrorCode.FurnitureEntryDoesntExist, api);
            return null;
        }

        // Update the entry object itself
        entry.setRow(row);
        entry.setColumn(column);
        entry.setInWorld(inWorld);

        // Update the database
        handle.createStatement( "sql/MoveFurniture.sql" )
                .bind("row", row )
                .bind("column", column )
                .bind("inWorld", inWorld ? "T" : "F" )
                .bind("id", entryId )
                .execute();

        // Give the success message to the caller
        MessagingHelper.sendSuccessMessage(Command.MoveFurniture, user, api);

        // Tell users of the updated entry
        EsObject event = new EsObject();
        event.setInteger(Field.FurnitureEntryId.getCode(), entryId);
        event.setInteger(Field.Row.getCode(), row);
        event.setInteger(Field.Column.getCode(), column);
        event.setBoolean(Field.InWorld.getCode(), inWorld);
        MessagingHelper.sendEventToRoom(Command.FurnitureUpdate, event, api);
        
        return null;
    }

}
