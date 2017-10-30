package com.gamebook.oldworld;

import com.electrotank.electroserver4.extensions.api.value.EsObject;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;

import org.skife.jdbi.v2.Handle;
import org.skife.jdbi.v2.Query;
import org.skife.jdbi.v2.TransactionStatus;
import org.skife.jdbi.v2.Update;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.gamebook.util.CollectionHelper;

/** Helper methods that are used across Processor implementations */
public class ProcessorHelper {

    /**
     * Convert a Collection of values into an EsObject structure that will feign the array response used in SFS
     *
     * @param values Values to convert
     *
     * @return EsObject containing values
     */
    public static EsObject toEsObject( Collection<?> values ) {
        Object[] entries = new Object[( values.size() << 1 )];
        int index = 0;
        int i = 0;

        for ( Object value : values ) {
            entries[index++] = String.valueOf( i++ );
            entries[index++] = value;
        }

        EsObject esObject = new EsObject( entries );

        esObject.setInteger( "len", values.size() );

        return esObject;
    }

    private static final Logger logger = LoggerFactory.getLogger( ProcessorHelper.class );

    /**
     * Create an EsObject response for a logical "command"
     *
     * @param command Command code
     * @param values  Command values
     *
     * @return EsObject for command
     */
    public static EsObject toCommand( String command, Collection<Object> values ) {
        EsObject esObject = toEsObject( values );

        esObject.setString( "cmd", command );

        return esObject;
    }

    public static EsObject toCommand( String command, Object... values ) {
        return toCommand( command, null == values ? Collections.emptyList() : Arrays.asList( values ) );
    }

    public static boolean updateSingleRow( Update update, TransactionStatus status ) {
        boolean success = update.execute() == 1;

        if ( !success ) {
            status.setRollbackOnly();
        }

        return success;
    }

    public static Query<?> createVariableLengthInClause( Handle handle,
                                                         String beforeIn,
                                                         String afterIn,
                                                         Collection<?> values,
                                                         int startingPosition )
    {
        String[] placeholders = new String[values.size()];
        Arrays.fill( placeholders, "?" );
        Query<?> query =
            handle.createQuery( beforeIn + CollectionHelper.join( Arrays.asList( placeholders ), "," ) + afterIn );

        for ( Object value : values ) {
            query.bind( startingPosition++, value );
        }

        return query;
    }

}
