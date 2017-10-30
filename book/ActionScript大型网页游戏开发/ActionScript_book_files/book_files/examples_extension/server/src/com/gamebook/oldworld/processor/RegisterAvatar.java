package com.gamebook.oldworld.processor;

import com.electrotank.electroserver4.extensions.api.PluginApi;
import com.electrotank.electroserver4.extensions.api.value.EsObjectRO;
import com.gamebook.oldworld.Command;
import com.gamebook.oldworld.ErrorCode;
import com.gamebook.oldworld.Field;
import com.gamebook.oldworld.MessagingHelper;
import com.gamebook.oldworld.UserType;
import com.gamebook.oldworld.model.Gender;
import java.util.Map;
import org.skife.jdbi.v2.DBI;
import org.skife.jdbi.v2.Handle;
import org.skife.jdbi.v2.TransactionCallback;
import org.skife.jdbi.v2.TransactionStatus;

public class RegisterAvatar extends AbstractProcessor {

    // DEFAULTS
    private int defaultMoney = 1000;
    private int defaultMaleTop = 8;
    private int defaultMaleBottom = 10;
    private int defaultMaleShoes = 12;
    private int[] maleInitialItems = new int[] { 8, 9, 10, 11, 12, 13, 14, 15};
    private int defaultFemaleTop = 3;
    private int defaultFemaleBottom = 5;
    private int defaultFemaleShoes = 6;
    private int[] femaleInitialItems = new int[] { 1, 2, 3, 4, 5, 6, 7 };

    public RegisterAvatar( DBI dbi ) {
        super( dbi );
    }

    @Override
    public String getCommand() {
        return Command.RegisterAvatar.getCode();
    }

    @Override
    public UserType getAllowedUserType() {
        return UserType.Guest;
    }

    @Override
    public void process( final String user, final EsObjectRO message, final PluginApi api ) {

        // Look up their account in the database via the username/password
        boolean success = dbi.inTransaction( new TransactionCallback<Boolean>() {
            @Override
            public Boolean inTransaction( Handle handle, TransactionStatus status ) throws Exception {
                return createAvatar( handle, user, message, api );
            }
        } );

        if(success) {
            MessagingHelper.sendSuccessMessage(Command.RegisterAvatar, user, api);
        }

    }

    private boolean createAvatar(Handle handle, String user, EsObjectRO message, PluginApi api) {

        // Pull the fields from the request
        String username = message.getString(Field.AvatarName.getCode());
        String password = message.getString(Field.AvatarPassword.getCode());
        Gender gender = Gender.findByCharacterCode(message.getString(Field.AvatarGender.getCode()));
        int hairstyle = message.getInteger(Field.AvatarHair.getCode());

        // See if the avatar already exists, if so, fail
        int avatarId = findIdOfAvatar(handle, username);
        if(avatarId != -1) {
            MessagingHelper.sendErrorMessage(Command.RegisterAvatar, user, ErrorCode.AvatarNameAlreadyExists, api);
            return false;
        }

        //TODO: validate the values exist and that the hairstyle is legit

        int top = defaultMaleTop;
        int bottom = defaultMaleBottom;
        int shoes = defaultMaleShoes;
        int[] itemsToAdd = maleInitialItems;
        if(gender == Gender.Female) {
            top = defaultFemaleTop;
            bottom = defaultFemaleBottom;
            shoes = defaultFemaleShoes;
            itemsToAdd = femaleInitialItems;
        }
        
        // Create the query
        handle.createStatement( "sql/CreateAvatar.sql" )
            .bind("username", username )
            .bind("password", password)
            .bind("money", defaultMoney)
            .bind("hairstyle", hairstyle)
            .bind("gender", gender.getCharacterCode())
            .bind("top", top)
            .bind("bottom", bottom)
            .bind("shoes", shoes)
            .execute();

        // Now look up the id of the avatar we just created
        avatarId = findIdOfAvatar(handle, username);

        // Iterate over the clothing and add each entry to their inventory
        for(int clothingId : itemsToAdd) {
            handle.createStatement( "sql/InsertAvatarClothing.sql" )
                    .bind("clothingId", clothingId)
                    .bind("avatarId", avatarId)
                    .execute();
        }

        return true;
    }

    private int findIdOfAvatar(Handle handle, String username) {
        Map<String, Object> results = handle.createQuery( "sql/FindAvatarByName.sql" )
            .bind( "username", username )
            .first();

        if(results != null && results.containsKey("id")) {
            return (Integer) results.get("id");
        } else {
            return -1;
        }
    }
}
