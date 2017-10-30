package com.gamebook.oldworld;

import com.gamebook.oldworld.processor.AddBuddy;
import com.gamebook.oldworld.processor.BuyItem;
import com.gamebook.oldworld.processor.EquipClothing;
import com.gamebook.oldworld.processor.LoadAreaDetails;
import com.gamebook.oldworld.processor.LoadBuddies;
import com.gamebook.oldworld.processor.MoveFurniture;
import com.gamebook.oldworld.processor.RegisterAvatar;
import com.gamebook.oldworld.processor.RemoveBuddy;
import com.gamebook.oldworld.processor.Walk;
import java.util.HashMap;
import java.util.Map;

import org.skife.jdbi.v2.DBI;

/**
 * Manage all of the {@link Processor} instances
 *
 */
public class Processors {

    private final Map<String, Processor> processors = new HashMap<String, Processor>();

    public Processors( DBI dbi ) {
      
        register(new BuyItem(dbi));
        register(new EquipClothing(dbi));
        register(new RegisterAvatar(dbi));
        register(new LoadAreaDetails(dbi));
        register(new Walk(dbi));
        register(new AddBuddy(dbi));
        register(new RemoveBuddy(dbi));
        register(new LoadBuddies(dbi));
        register(new MoveFurniture(dbi));
    }

    private void register( Processor processor ) {

        // Ensure a command was specified
        if(processor.getCommand() == null || processor.getCommand().length() == 0) {
            throw new IllegalStateException("Attempted to register a processor that has a null or empty command! Processor details: " + processor);
        }

        // Ensure the allowed user type was specified
        if(processor.getAllowedUserType() == null) {
            throw new IllegalStateException("The processor registered for the '" + processor.getCommand() + "' command has no specified user type!");
        }

        // Register the processor
        Processor existing = processors.put( processor.getCommand(), processor );

        // If we have two processors with the same command, throw an exception
        if ( existing != null ) {
            throw new IllegalStateException(
                "Two processors registered for the '" + processor.getCommand() + "' command, " + processor + " and " +
                existing );
        }
    }

    public Processor forCommand( String command ) {
        return processors.get( command );
    }
}
