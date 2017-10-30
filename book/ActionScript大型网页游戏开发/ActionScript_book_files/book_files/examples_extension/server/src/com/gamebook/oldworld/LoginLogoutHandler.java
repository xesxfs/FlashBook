package com.gamebook.oldworld;

import com.electrotank.electroserver4.extensions.ChainAction;
import com.electrotank.electroserver4.extensions.LoginContext;
import com.electrotank.electroserver4.extensions.LoginEventHandler;
import com.electrotank.electroserver4.extensions.LogoutEventHandler;
import com.electrotank.electroserver4.extensions.api.value.EsObject;
import com.gamebook.oldworld.model.Avatar;
import com.gamebook.oldworld.model.ClothingItem;
import com.gamebook.oldworld.model.ClothingType;
import com.gamebook.oldworld.model.FurnitureEntry;
import com.gamebook.oldworld.model.FurnitureItem;
import com.gamebook.oldworld.model.Gender;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.skife.jdbi.v2.Handle;
import org.skife.jdbi.v2.TransactionCallback;
import org.skife.jdbi.v2.TransactionStatus;


public class LoginLogoutHandler extends AbstractLoginLogoutEventHandler
    implements LoginEventHandler, LogoutEventHandler
{
    @Override
    public ChainAction executeLogin( final LoginContext context ) {

        // Get the username
        final String userName = context.getUserName();

        // If there are logging in as a guest, set the UserType and randomize their username
        if(userName.equalsIgnoreCase("guest")) {
            getApi().getLogger().debug("guest logging in");

            // Randomize their username to avoid conflicts with existing users
            int count = 0;
            String name = "User" + Math.random();
            while(getApi().isUserLoggedIn(name)) {
                count++;
                name = "User" + Math.random();
                if(count > 100) {
                    throw new RuntimeException("Unable to generate a unique username!");
                }
            }
            context.setUserName( name );
            
            // Set the user type
            context.addExtensionBoundUserServerVariable(ExtensionBoundField.UserType.toString(), UserType.Guest);

            if(logger.isDebugEnabled()) {
                logger.debug("Guest logged in as " + name);
            }

        } else { // If here, then they are not logging in as a guest

            final String password = context.getPassword();
            getApi().getLogger().debug("{} logging in", userName);

            // Look up the clothing and furniture maps
            @SuppressWarnings("unchecked")
            final Map<Integer, ClothingItem> clothingMap = (Map<Integer, ClothingItem>) getApi().acquireManagedObject(ExtensionBoundField.ControllerFactory.toString(),
                    new EsObject(ExtensionBoundField.ObjectName.toString(), ExtensionBoundField.ClothingMap.toString()));

            @SuppressWarnings("unchecked")
            final Map<Integer, FurnitureItem> furnitureMap = (Map<Integer, FurnitureItem>) getApi().acquireManagedObject(ExtensionBoundField.ControllerFactory.toString(),
                    new EsObject(ExtensionBoundField.ObjectName.toString(), ExtensionBoundField.FurnitureMap.toString()));

            // Look up their account in the database via the username/password
            Avatar avatar = getController().getDbi().inTransaction( new TransactionCallback<Avatar>() {
                @Override
                public Avatar inTransaction( Handle handle, TransactionStatus status ) throws Exception {
                    return loadAvatar( handle, userName, password, clothingMap, furnitureMap, context );
                }
            } );

            // Get the response parameters
            EsObject response = context.getResponseParameters();

            // If we failed to load an avatar
            if(avatar == null) {

                // Update the response with a failure
                MessagingHelper.buildErrorMessage(null, ErrorCode.InvalidUsernameOrPassword, response);

                // Fail the login process
                return ChainAction.Fail;
            }

            // Populate the response with avatar data
            response.setEsObject(Field.Avatar.getCode(), avatar.toEsObject(true));
            response.setEsObjectArray(Field.FurnitureArray.getCode(), createFurnitureArray(furnitureMap));
            response.setEsObjectArray(Field.ClothingTypeArray.getCode(), ClothingType.toEsObjectArray());
            response.setEsObjectArray(Field.ClothingArray.getCode(), createClothingArray(clothingMap)); 

            // Set the user type
            context.addExtensionBoundUserServerVariable(ExtensionBoundField.UserType.toString(), UserType.Player);

            if(logger.isDebugEnabled()) {
                logger.debug("Player logged in as " + userName);
                logger.debug("response == null? " + (response == null));
                logger.debug("Attached esob: " + response.toString());
            }
        }

        return ChainAction.OkAndContinue;
    }

    private EsObject[] createFurnitureArray(Map<Integer, FurnitureItem> furnitureMap) {

        List<EsObject> output = new ArrayList<EsObject>();

        for(FurnitureItem furnitureItem : furnitureMap.values()) {
            output.add(furnitureItem.toEsObject());
        }

        return (EsObject[]) output.toArray( new EsObject[output.size()] );
    }

    private EsObject[] createClothingArray(Map<Integer, ClothingItem> clothingMap) {

        List<EsObject> output = new ArrayList<EsObject>();

        for(ClothingItem clothingItem : clothingMap.values()) {
            output.add(clothingItem.toEsObject());
        }

        return (EsObject[]) output.toArray( new EsObject[output.size()] );
    }

    private Avatar loadAvatar(Handle handle, String username, String password, Map<Integer, ClothingItem> clothingMap, Map<Integer, FurnitureItem> furnitureMap, LoginContext context) {

        // Load the avatar
        List<Map<String, Object>> avatarResults = handle.createQuery( "sql/LoadAvatar.sql" )
            .bind( "name", username )
            .bind("password", password)
            .list(1);

        // Make sure we got something
        if(avatarResults.size() == 0) {
            return null;
        }

        // Get the first (and only entry)
        Map<String, Object> avatarEntry = avatarResults.get(0);

        // Create the initial avatar
        Avatar avatar = new Avatar();
        avatar.setId( (Integer) avatarEntry.get("id") );
        avatar.setName( username );
        avatar.setPassword( password );
        avatar.setGender( Gender.findByCharacterCode( (String) avatarEntry.get("gender") ) );
        avatar.setMoney( (Integer) avatarEntry.get("money") );

        // Handle loading all the clothing the user is wearing
        avatar.setHair( clothingMap.get( (Integer) avatarEntry.get("hairstyle") ) );
        avatar.setTop( clothingMap.get( (Integer) avatarEntry.get("clothingtop") ) );
        avatar.setBottom( clothingMap.get( (Integer) avatarEntry.get("clothingbottom") ) );
        avatar.setShoes( clothingMap.get( (Integer) avatarEntry.get("shoes") ) );

        //Look up the clothing inventory
        List<Map<String, Object>> clothingResults = handle.createQuery( "sql/LoadAvatarClothing.sql" )
            .bind( "avatarId", avatar.getId() )
            .list();

        // Create the list to hold em all
        List<ClothingItem> clothingList = new ArrayList<ClothingItem>(clothingResults.size());

        // Iterate over all the clothing buddyEntries to look them up
        for(Map<String, Object> clothingEntry : clothingResults ) {

            // Look up the piece of clothing
            int clothingId = (Integer) clothingEntry.get("clothingid");
            ClothingItem clothing = clothingMap.get(clothingId);

            // Add the clothing to the list
            clothingList.add(clothing);
        }

        // Add the clothing to the avatar
        avatar.setClothingInventory(clothingList);

        // Add the avatar into the "session" so we can access it later
        context.addExtensionBoundUserServerVariable(ExtensionBoundField.Avatar.toString(), avatar);

        //Look up the avatar's buddies
        List<Map<String, Object>> buddyResults = handle.createQuery( "sql/LoadAvatarBuddies.sql" )
            .bind( "avatarId", avatar.getId() )
            .list();

        // Get access to the map that will store the buddies
        Map<String, EsObject> buddyEntries = new HashMap<String, EsObject>();
        
        // Notify ElectroServer about each buddy so it can handle notifications
        for(Map<String, Object> entry : buddyResults) {
            buddyEntries.put((String) entry.get("name"), new EsObject());
        }

        context.setBuddyListEntries(buddyEntries);

        // Return the newly populated avatar
        return avatar;
    }

    @Override
    public void executeLogout( final String userName ) {

    }

}
