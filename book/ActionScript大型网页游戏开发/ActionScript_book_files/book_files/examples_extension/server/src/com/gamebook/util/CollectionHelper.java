package com.gamebook.util;

import java.util.Collection;

/** @author <a href="mailto:peter@electrotank.com">peter royal</a> */
public class CollectionHelper {

    public static String join( Collection<?> collection, String separator ) {
        StringBuilder output = new StringBuilder( collection.size() * 20 );

        for ( Object o : collection ) {
            output.append( o ).append( separator );
        }

        return output.substring( 0, output.length() - separator.length() );
    }
}
