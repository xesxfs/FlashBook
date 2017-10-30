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
import java.util.List;
import java.util.Map;
import org.skife.jdbi.v2.DBI;
import org.skife.jdbi.v2.Handle;
import org.skife.jdbi.v2.TransactionCallback;
import org.skife.jdbi.v2.TransactionStatus;

public class AddBuddy extends AbstractProcessor {

    public AddBuddy( DBI dbi ) {
        super( dbi );
    }

    @Override
    public String getCommand() {
        return Command.AddBuddy.getCode();
    }

    @Override
    public UserType getAllowedUserType() {
        return UserType.Player;
    }

    @Override
    public void process( final String user, final EsObjectRO message, final PluginApi api ) {

        // Try and add the buddy
        boolean success = dbi.inTransaction( new TransactionCallback<Boolean>() {
            @Override
            public Boolean inTransaction( Handle handle, TransactionStatus status ) throws Exception {
                return processBuddyRequest( Command.AddBuddy, handle, user, message, api );
            }
        } );

        if(success) {
            MessagingHelper.sendSuccessMessage(Command.AddBuddy, user, api);
        }

    }

    public static boolean processBuddyRequest(Command command, Handle handle, String user, EsObjectRO message, PluginApi api) {

        // Get the avatar
        Avatar avatar = (Avatar) api.getExtensionBoundUserServerVariable(user, ExtensionBoundField.Avatar.toString()).getValue();

        // Get the buddy ID from the request
        int buddyId = message.getInteger(Field.BuddyId.getCode());

        //Look up the buddy name
        List<Map<String, Object>> searchResults = handle.createQuery( "sql/FindAvatarNameById.sql" )
            .bind( "avatarId", buddyId )
            .list();

        // If we didnt find anything, it's an invalid id
        if(searchResults == null || searchResults.size() == 0) {
            MessagingHelper.sendErrorMessage(command, user, ErrorCode.BuddyIdIsInvalid, api);
            return false;
        }

        // Get the name from the results
        String buddyName = (String) searchResults.get(0).get("name");

        // Determine the right sql statement and tell ElectroServer what to do
        String sql = null;
        if(command == Command.RemoveBuddy) {
            sql = "sql/RemoveBuddy.sql";
            api.removeBuddy(user, buddyName);
        } else {
            sql = "sql/AddBuddy.sql";
            api.addBuddy(user, buddyName, new EsObject());
        }

        // Either add or delete from the database as needed
        handle.createStatement( sql )
                .bind("avatarId", avatar.getId() )
                .bind("buddyId", buddyId)
                .execute();

        // Return the success
        return true;
    }
}
