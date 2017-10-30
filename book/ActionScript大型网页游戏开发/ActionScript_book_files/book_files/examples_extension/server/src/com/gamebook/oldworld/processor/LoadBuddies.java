package com.gamebook.oldworld.processor;

import com.electrotank.electroserver4.extensions.api.PluginApi;
import com.electrotank.electroserver4.extensions.api.value.EsObject;
import com.electrotank.electroserver4.extensions.api.value.EsObjectRO;
import com.gamebook.oldworld.Command;
import com.gamebook.oldworld.ExtensionBoundField;
import com.gamebook.oldworld.Field;
import com.gamebook.oldworld.MessagingHelper;
import com.gamebook.oldworld.UserType;
import com.gamebook.oldworld.model.Avatar;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import org.skife.jdbi.v2.DBI;
import org.skife.jdbi.v2.Handle;
import org.skife.jdbi.v2.TransactionCallback;
import org.skife.jdbi.v2.TransactionStatus;

public class LoadBuddies extends AbstractProcessor {

    public LoadBuddies( DBI dbi ) {
        super( dbi );
    }

    @Override
    public String getCommand() {
        return Command.LoadBuddies.getCode();
    }

    @Override
    public UserType getAllowedUserType() {
        return UserType.Player;
    }

    @Override
    public void process( final String user, final EsObjectRO message, final PluginApi api ) {

        // Try and load the buddies
        dbi.inTransaction( new TransactionCallback<Object>() {
            @Override
            public Object inTransaction( Handle handle, TransactionStatus status ) throws Exception {
                return loadBuddies( handle, user, api );
            }
        } );

    }

    private Object loadBuddies(Handle handle, String user, PluginApi api) {

        // Get the avatar from session
        Avatar avatar = (Avatar) api.getExtensionBoundUserServerVariable(user, ExtensionBoundField.Avatar.toString()).getValue();

        //Look up the buddies
        List<Map<String, Object>> queryResults = handle.createQuery( "sql/LoadAvatarBuddies.sql" )
            .bind( "avatarId", avatar.getId() )
            .list();

        // Prime the results
        EsObject results = new EsObject();

        List<EsObject> buddyList = new ArrayList<EsObject>();

        // Iterate over the buddies and add them as we go
        for(Map<String, Object> buddy : queryResults) {

            String buddyName = (String) buddy.get("name");

            EsObject buddyObject = new EsObject();
            buddyObject.setInteger(Field.BuddyId.getCode(), (Integer) buddy.get("buddyId"));
            buddyObject.setString(Field.BuddyName.getCode(), buddyName);
            buddyObject.setBoolean(Field.BuddyLoggedIn.getCode(), api.isUserLoggedIn(buddyName));

            buddyList.add(buddyObject);

        }

        // Add the buddies to the array
        results.setEsObjectArray(Field.BuddyList.getCode(), (EsObject[]) buddyList.toArray(new EsObject[buddyList.size()]));

        // Send the success message with details
        MessagingHelper.sendSuccessMessage(Command.LoadBuddies, user, results, api);

        return null;
    }

}
