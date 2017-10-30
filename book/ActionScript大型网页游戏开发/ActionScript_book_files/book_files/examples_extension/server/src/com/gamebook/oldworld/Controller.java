package com.gamebook.oldworld;

import org.apache.commons.dbcp.BasicDataSource;
import org.apache.commons.dbcp.BasicDataSourceFactory;
import org.skife.jdbi.v2.DBI;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.electrotank.electroserver4.extensions.api.PluginApi;
import com.electrotank.electroserver4.extensions.api.value.EsObject;
import com.electrotank.electroserver4.extensions.api.value.EsObjectRO;
import java.util.Properties;

/**
 * Main controller for all application logic
 *
 */
public class Controller {
    private static final Logger logger = LoggerFactory.getLogger( Controller.class );

    private final BasicDataSource dataSource;
    private final Processors processors;
    private final DBI dbi;

    public Controller( Properties properties ) throws Exception {
        this.dataSource = newDataSource( properties );
        this.dbi = new DBI( dataSource );
        this.processors = new Processors( dbi );
    }

    private BasicDataSource newDataSource( Properties properties ) throws Exception {
        Properties databaseProperties = new Properties();

        for ( String key : properties.stringPropertyNames() ) {
            if ( key.startsWith( "database." ) ) {
                databaseProperties.setProperty( key.substring( 9 ), properties.getProperty( key ) );
            }
        }
        
        return (BasicDataSource) BasicDataSourceFactory.createDataSource( databaseProperties );
    }

    public void dispose() throws Exception {
        dataSource.close();
    }

    public DBI getDbi() {
        return dbi;
    }

    public void handleRequest( String user, UserType userType, EsObjectRO message, PluginApi api ) {
        EsObject obj = (EsObject) message;
        api.getLogger().debug("request from " + user + " : " + message.toString());
        String command = message.getString( Field.Command.getCode() );

        if ( null == command ) {
            throw new IllegalArgumentException( "Message is missing the command field - '" + Field.Command.getCode() + "'");
        }

        // Get the processor
        Processor processor = processors.forCommand( command );

        // Make sure we could find it
        if ( null == processor ) {
            throw new IllegalArgumentException( "No processor for command '" + command + "'" );
        }

        // Ensure the user type matches what the processor expects
        if(processor.getAllowedUserType() != userType) {
            throw new IllegalArgumentException("Attempted to call a processor with the wrong UserType. " +
                    "The UserType of '" + userType + "' was used but '" + processor.getAllowedUserType() + "' was expected!");
        }

        // Process the request
        processor.process( user, message, api );
    }

}
