package com.gamebook.oldworld.processor;

import com.gamebook.oldworld.Processor;
import org.skife.jdbi.v2.DBI;

public abstract class AbstractProcessor implements Processor {

    protected final DBI dbi;

    public AbstractProcessor( DBI dbi ) {
        this.dbi = dbi;
    }

}
