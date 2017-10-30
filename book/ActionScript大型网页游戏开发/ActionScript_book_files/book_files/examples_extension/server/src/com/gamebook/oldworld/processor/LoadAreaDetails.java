package com.gamebook.oldworld.processor;

import com.electrotank.electroserver4.extensions.api.PluginApi;
import com.electrotank.electroserver4.extensions.api.value.EsObject;
import com.electrotank.electroserver4.extensions.api.value.EsObjectRO;
import com.gamebook.oldworld.AreaPlugin;
import com.gamebook.oldworld.Command;
import com.gamebook.oldworld.ExtensionBoundField;
import com.gamebook.oldworld.Field;
import com.gamebook.oldworld.MessagingHelper;
import com.gamebook.oldworld.UserType;
import com.gamebook.oldworld.model.Avatar;
import com.gamebook.oldworld.model.FurnitureEntry;
import com.gamebook.oldworld.model.Path;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import org.skife.jdbi.v2.DBI;

public class LoadAreaDetails extends AbstractProcessor {

    public LoadAreaDetails( DBI dbi ) {
        super( dbi );
    }

    @Override
    public String getCommand() {
        return Command.LoadAreaDetails.getCode();
    }

    @Override
    public UserType getAllowedUserType() {
        return UserType.Player;
    }

    @Override
    public void process( final String user, final EsObjectRO message, final PluginApi api ) {
        
        // Get the plugin as we need to access parts of it
        AreaPlugin plugin = (AreaPlugin) api.getRoomPlugin(api.getZoneId(), api.getRoomId(), "AreaPlugin");

        // Get the list of users for the room
        Collection<String> users = api.getUsers();
        
        // Create the ESObject to hold the entire message
        EsObject response = new EsObject();
        
        // Create a list to hold all the avatars
        List<EsObject> avatars = new ArrayList<EsObject>(users.size());
        
        // Iterate over all the avatars in the room
        for(String currentUser : users) {
            
            // Get the avatar and path info for the current user
            Avatar avatar = (Avatar) api.getUserPluginVariable(currentUser, ExtensionBoundField.Avatar.toString());
            Path path = (Path) api.getUserPluginVariable(currentUser, ExtensionBoundField.Path.toString());
            
            // Format the avatar and add the path if needed
            EsObject formattedAvatar = avatar.toEsObject(false);
            if(path != null) {
                formattedAvatar.setEsObject(Field.Path.getCode(), path.toEsObject());
            }

            // Add it to the list of avatars
            avatars.add(formattedAvatar);
        }
        
        // Add the list of avatars to the main response
        response.setEsObjectArray(Field.Avatars.getCode(), 
                (EsObject[]) avatars.toArray(new EsObject[avatars.size()]));
        
        // If this is a users room, we need to send the furniture details
        if(plugin.isOwned()) {

            // Get the furniture and turn it into an array of furniture esobjects
            Map<Integer, FurnitureEntry> map = plugin.getFurnitureEntryMap();
            List<EsObject> furnitureList = new ArrayList<EsObject>(map.size());
            for(FurnitureEntry entry : map.values()) {
                furnitureList.add(entry.toEsObject());
            }
            EsObject[] furniture = (EsObject[]) furnitureList.toArray(new EsObject[furnitureList.size()]);

            response.setEsObjectArray(Field.FurnitureList.getCode(), furniture);
        }
        
        // Send the data to the user
        MessagingHelper.sendSuccessMessage(Command.LoadAreaDetails, user, response, api);
        
    }
   
}
