package com.gamebook.oldworld;

import com.electrotank.electroserver4.extensions.ChainAction;
import com.electrotank.electroserver4.extensions.RoomUserEvents;
import com.electrotank.electroserver4.extensions.api.value.EsObject;
import com.electrotank.electroserver4.extensions.api.value.EsObjectRO;
import com.electrotank.electroserver4.extensions.api.value.UserEnterContext;
import com.electrotank.electroserver4.extensions.api.value.UserPublicMessageContext;
import com.gamebook.oldworld.model.Avatar;
import com.gamebook.oldworld.model.FurnitureEntry;
import com.gamebook.oldworld.model.FurnitureItem;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.skife.jdbi.v2.Handle;
import org.skife.jdbi.v2.TransactionCallback;
import org.skife.jdbi.v2.TransactionStatus;

public class AreaPlugin extends WorldPlugin implements RoomUserEvents {

    private boolean owned = false;
    private String ownerName;
    private Map<Integer, FurnitureEntry> furnitureEntryMap;

    @Override
    public void init(EsObjectRO esObjectRO) {
        super.init(esObjectRO);

        // All of this is only necessary if the room has an owner
        if(esObjectRO.variableExists(Field.RoomOwner.getCode())) {

            // Get the owner of the room
            setOwned(true);
            setOwnerName(esObjectRO.getString(Field.RoomOwner.getCode()));

            // Create the map to hold all the furniture entries
            setFurnitureEntryMap(new HashMap<Integer, FurnitureEntry>());

            // Try and load the furniture
            getController().getDbi().inTransaction( new TransactionCallback<Object>() {
                @Override
                public Object inTransaction( Handle handle, TransactionStatus status ) throws Exception {
                    return loadFurniture( handle, getOwnerName() );
                }
            } );

        } // end "owner" if statement

    }

    private Object loadFurniture(Handle handle, String username) {

        // Load the static map of all furniture in the system
        @SuppressWarnings("unchecked")
        Map<Integer, FurnitureItem> furnitureMap = (Map<Integer, FurnitureItem>) getApi().acquireManagedObject(ExtensionBoundField.ControllerFactory.toString(),
                new EsObject(ExtensionBoundField.ObjectName.toString(), ExtensionBoundField.FurnitureMap.toString()));

        //Look up the furniture inventory
        List<Map<String, Object>> furnitureResults = handle.createQuery( "sql/LoadAvatarFurnitureByName.sql" )
            .bind( "name", username )
            .list();

        // Iterate over all the furniture this user owns
        for(Map<String, Object> furnitureEntry : furnitureResults ) {

            // Create the furniture entry
            FurnitureEntry entry = new FurnitureEntry();
            entry.setId( (Integer) furnitureEntry.get("id"));
            entry.setRow( (Integer) furnitureEntry.get("rowposition"));
            entry.setColumn( (Integer) furnitureEntry.get("columnposition"));
            entry.setInWorld( ((String) furnitureEntry.get("inworld")).equalsIgnoreCase("T") ? true : false );

            // Look up the specific piece of furniture
            int furnitureId = (Integer) furnitureEntry.get("furnitureid");
            FurnitureItem furniture = furnitureMap.get(furnitureId);
            entry.setFurniture(furniture);

            // Add the entry to the list
            getFurnitureEntryMap().put(entry.getId(), entry);
        } // end furniture loop

        return null;
    }

    public ChainAction userEnter(UserEnterContext context) {
        String user = context.getUserName();
        
        // Get the avatar from the "session" and store it in  the local plugin scope for convenience
        Avatar avatar = (Avatar) getApi().getExtensionBoundUserServerVariable(user, ExtensionBoundField.Avatar.toString()).getValue();
        getApi().setUserPluginVariable(user, ExtensionBoundField.Avatar.toString(), avatar);  

        // Tell everyone that this avatar joined
        EsObject avatarData = avatar.toEsObject(false);
        EsObject event = new EsObject();
        event.setEsObject(Field.Avatar.getCode(), avatarData);
        MessagingHelper.sendEventToRoom(Command.AvatarJoined, event, getApi());

        return ChainAction.OkAndContinue;
    }

    public void userExit(String user) {

        EsObject event = new EsObject();
        event.setString(Field.AvatarName.getCode(), user);
        MessagingHelper.sendEventToRoom(Command.AvatarLeft, event, getApi());

    }

    public ChainAction userSendPublicMessage(UserPublicMessageContext arg0) {
        // Do nothing, we are not filtering chat messages
        return ChainAction.OkAndContinue;
    }
        
    public void userBanned(String arg0, String arg1, int arg2) {
       // Do nothing
    }

    public void userKicked(String arg0, String arg1) {
        // Do nothing
    }

    /**
     * @return the owned
     */
    public boolean isOwned() {
        return owned;
    }

    /**
     * @param owned the owned to set
     */
    public void setOwned(boolean owned) {
        this.owned = owned;
    }

    /**
     * @return the ownerName
     */
    public String getOwnerName() {
        return ownerName;
    }

    /**
     * @param ownerName the ownerName to set
     */
    public void setOwnerName(String ownerName) {
        this.ownerName = ownerName;
    }

    /**
     * @return the furnitureEntryMap
     */
    public Map<Integer, FurnitureEntry> getFurnitureEntryMap() {
        return furnitureEntryMap;
    }

    /**
     * @param furnitureEntryMap the furnitureEntryMap to set
     */
    public void setFurnitureEntryMap(Map<Integer, FurnitureEntry> furnitureEntryMap) {
        this.furnitureEntryMap = furnitureEntryMap;
    }

}
