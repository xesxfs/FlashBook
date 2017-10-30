package com.gamebook.oldworld.processor;

import com.electrotank.electroserver4.extensions.api.PluginApi;
import com.electrotank.electroserver4.extensions.api.value.EsObjectRO;
import com.gamebook.oldworld.Command;
import com.gamebook.oldworld.MessagingHelper;
import com.gamebook.oldworld.UserType;
import org.skife.jdbi.v2.DBI;
import org.skife.jdbi.v2.Handle;
import org.skife.jdbi.v2.TransactionCallback;
import org.skife.jdbi.v2.TransactionStatus;

public class RemoveBuddy extends AbstractProcessor {

    public RemoveBuddy( DBI dbi ) {
        super( dbi );
    }

    @Override
    public String getCommand() {
        return Command.RemoveBuddy.getCode();
    }

    @Override
    public UserType getAllowedUserType() {
        return UserType.Player;
    }

    @Override
    public void process( final String user, final EsObjectRO message, final PluginApi api ) {

        // Try and remove the buddy
        boolean success = dbi.inTransaction( new TransactionCallback<Boolean>() {
            @Override
            public Boolean inTransaction( Handle handle, TransactionStatus status ) throws Exception {
                return AddBuddy.processBuddyRequest( Command.RemoveBuddy, handle, user, message, api );
            }
        } );

        if(success) {
            MessagingHelper.sendSuccessMessage(Command.RemoveBuddy, user, api);
        }

    }

}
