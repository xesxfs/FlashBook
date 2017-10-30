package com.gamebook.oldworld.processor;

import com.electrotank.electroserver4.extensions.api.PluginApi;
import com.electrotank.electroserver4.extensions.api.value.EsObject;
import com.electrotank.electroserver4.extensions.api.value.EsObjectRO;
import com.gamebook.oldworld.Command;
import com.gamebook.oldworld.ExtensionBoundField;
import com.gamebook.oldworld.Field;
import com.gamebook.oldworld.MessagingHelper;
import com.gamebook.oldworld.UserType;
import com.gamebook.oldworld.model.Path;
import org.skife.jdbi.v2.DBI;

public class Walk extends AbstractProcessor {

    public Walk( DBI dbi ) {
        super( dbi );
    }

    @Override
    public String getCommand() {
        return Command.Walk.getCode();
    }

    @Override
    public UserType getAllowedUserType() {
        return UserType.Player;
    }

    @Override
    public void process( final String user, final EsObjectRO message, final PluginApi api ) {

        // Create the path from the message
        Path path = new Path();
        path.setPath(message.getIntegerArray(Field.PathPoints.getCode()));
        path.setTimeComplete(message.getString(Field.TimeStarted.getCode()));

        // Store the path in a variable for users entering the room
        api.setUserPluginVariable(user, ExtensionBoundField.Path.toString(), path);

        // Send the response to the user
        MessagingHelper.sendSuccessMessage(Command.Walk, user, api);

        // Create the event and send the event to the room
        EsObject event = new EsObject();
        event.setString(Field.Command.getCode(), Command.PathUpdate.getCode());
        event.setString(Field.Avatar.getCode(), user);
        event.setEsObject(Field.Path.getCode(), path.toEsObject());
        MessagingHelper.sendEventToRoom(Command.Walk, event, api);
    }

}
