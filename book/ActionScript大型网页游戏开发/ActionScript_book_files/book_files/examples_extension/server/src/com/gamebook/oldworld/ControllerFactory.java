package com.gamebook.oldworld;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.electrotank.electroserver4.extensions.ManagedObjectFactory;
import com.electrotank.electroserver4.extensions.ManagedObjectFactoryLifeCycle;
import com.electrotank.electroserver4.extensions.api.ManagedObjectFactoryApi;
import com.electrotank.electroserver4.extensions.api.value.EsObjectRO;
import com.gamebook.oldworld.model.ClothingItem;
import com.gamebook.oldworld.model.ClothingType;
import com.gamebook.oldworld.model.FurnitureItem;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.skife.jdbi.v2.Handle;
import org.skife.jdbi.v2.TransactionCallback;
import org.skife.jdbi.v2.TransactionStatus;

public class ControllerFactory implements ManagedObjectFactory, ManagedObjectFactoryLifeCycle {
    private static final Logger logger = LoggerFactory.getLogger( ControllerFactory.class );

    private ManagedObjectFactoryApi api;
    private Controller controller;

    private Map<Integer, ClothingItem> clothingMap;
    private Map<Integer, FurnitureItem> furnitureMap;

    @Override
    public void init( EsObjectRO parameters ) {
        try {
            controller = new Controller( loadProperties( parameters ) );
        } catch( RuntimeException e ) {
            throw e;
        } catch( Exception e ) {
            throw new RuntimeException( "Unable to spin up controller", e );
        }


        try {
        // Look up all the clothing in the system
        clothingMap = controller.getDbi().inTransaction( new TransactionCallback<Map<Integer, ClothingItem>>() {
            @Override
            public Map<Integer, ClothingItem> inTransaction( Handle handle, TransactionStatus status ) throws Exception {
                return loadAllClothing( handle );
            }
        } );

        // Look up all the furniture in the system
        furnitureMap = controller.getDbi().inTransaction( new TransactionCallback<Map<Integer, FurnitureItem>>() {
            @Override
            public Map<Integer, FurnitureItem> inTransaction( Handle handle, TransactionStatus status ) throws Exception {
                return loadAllFurniture( handle );
            }
        } );
        } catch(Throwable t) {
            t.printStackTrace();
        }
        
    }

    private Properties loadProperties( EsObjectRO parameters ) {
        String fileName = parameters.getString( "propertiesFileName", "world.properties" );
        InputStream in = getClass().getResourceAsStream( "/" + fileName );

        if ( null == in ) {
            throw new IllegalStateException(
                "Unable to load properties file '" + fileName + "' as defined in 'propertiesFileName'" );
        }

        Properties properties = new Properties();

        try {
            properties.load( in );
        } catch( IOException e ) {
            throw new RuntimeException(
                "Unable to load properties file '" + fileName + "' as defined in 'propertiesFileName'", e );
        }

        return properties;
    }

    @Override
    public void destroy() {
        try {
            controller.dispose();
        } catch( Exception e ) {
            logger.error( "Unable to cleanly spin down", e );
        }
    }

    private Map<Integer, ClothingItem> loadAllClothing(Handle handle ) {

        Map<Integer, ClothingItem> clothing = new HashMap<Integer, ClothingItem>();

        // Load the clothing
        List<Map<String, Object>> clothingResults = handle.createQuery( "sql/LoadAllClothing.sql" ).list();

        // Iterate over all the entries
        for(Map<String, Object> entry : clothingResults) {

            // Create the item
            ClothingItem clothingItem = new ClothingItem();

            // Populate it
            clothingItem.setId( (Integer) entry.get("id"));
            clothingItem.setName( (String) entry.get("name"));
            clothingItem.setFileName( (String) entry.get("filename"));
            clothingItem.setCost( (Integer) entry.get("cost"));
            clothingItem.setClothingType( ClothingType.findById((Integer) entry.get("clothingtype")));

            // Add it to the map
            clothing.put(clothingItem.getId(), clothingItem);
        }

        return clothing;
    }

    private Map<Integer, FurnitureItem> loadAllFurniture(Handle handle ) {

        Map<Integer, FurnitureItem> furniture = new HashMap<Integer, FurnitureItem>();

        // Load the clothing
        List<Map<String, Object>> furnitureResults = handle.createQuery( "sql/LoadAllFurniture.sql" ).list();

        // Iterate over all the entries
        for(Map<String, Object> entry : furnitureResults) {

            // Create the item
            FurnitureItem furnitureItem = new FurnitureItem();

            // Populate it
            furnitureItem.setId( (Integer) entry.get("id"));
            furnitureItem.setName( (String) entry.get("name"));
            furnitureItem.setFileName( (String) entry.get("filename"));
            furnitureItem.setCost( (Integer) entry.get("cost"));

            // Add it to the map
            furniture.put(furnitureItem.getId(), furnitureItem);
        }

        return furniture;
    }

    public Object acquireObject(EsObjectRO arg) {

        String objectName = arg.getString(ExtensionBoundField.ObjectName.toString());

        switch(ExtensionBoundField.valueOf(objectName)) {
            case ClothingMap:
                return clothingMap;
            case FurnitureMap:
                return furnitureMap;
            case Controller:
                return controller;
            default:
                throw new RuntimeException("Unmapped field specified?");
        }

    }

    @Override
    public void releaseObject(Object arg0) {
        throw new UnsupportedOperationException("Not supported");
    }

    @Override
    public ManagedObjectFactoryApi getApi() {
        return api;
    }

    @Override
    public void setApi( ManagedObjectFactoryApi api ) {
        this.api = api;
    }
}
