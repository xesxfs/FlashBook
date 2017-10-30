package com.gamebook.oldworld.model;

import com.electrotank.electroserver4.extensions.api.value.EsObject;
import com.gamebook.oldworld.Field;

public class Path {

    private int[] path;
    private String timeComplete;

    public EsObject toEsObject() {

        EsObject out = new EsObject();

        out.setIntegerArray(Field.PathPoints.getCode(), path);
        out.setString(Field.TimeStarted.getCode(), timeComplete);

        return out;
    }

    /**
     * @return the path
     */
    public int[] getPath() {
        return path;
    }

    /**
     * @param path the path to set
     */
    public void setPath(int[] path) {
        this.path = path;
    }

    /**
     * @return the timeComplete
     */
    public String getTimeComplete() {
        return timeComplete;
    }

    /**
     * @param timeComplete the timeComplete to set
     */
    public void setTimeComplete(String timeComplete) {
        this.timeComplete = timeComplete;
    }

}
