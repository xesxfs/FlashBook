package com.gamebook.oldworld;

import com.electrotank.electroserver4.extensions.api.PluginApi;
import com.electrotank.electroserver4.extensions.api.value.EsObject;

public class MessagingHelper {

    public static EsObject buildErrorMessage(Command command, ErrorCode errorCode, EsObject message) {
        if(command != null) {
            message.setString(Field.Command.getCode(), command.getCode());
        }
        message.setString(Field.Type.getCode(), Field.Response.getCode());
        message.setString(Field.Status.getCode(), Field.Failure.getCode());
        message.setString(Field.ErrorCode.getCode(), errorCode.getErrorCode());
        return message;
    }

    public static EsObject buildErrorMessage(Command command, ErrorCode errorCode) {
        return buildErrorMessage(command, errorCode, new EsObject());
    }

    public static EsObject buildSuccessMessage(Command command, EsObject message) {
        message.setString(Field.Command.getCode(), command.getCode());
        message.setString(Field.Type.getCode(), Field.Response.getCode());
        message.setString(Field.Status.getCode(), Field.Success.getCode());
        return message;
    }

    public static EsObject buildSuccessMessage(Command command) {
        return buildSuccessMessage(command, new EsObject());
    }

    public static void sendErrorMessage(Command command, String username, ErrorCode errorCode, PluginApi api) {
        EsObject message = buildErrorMessage(command, errorCode);
        sendMessage(username, message, api);
    }

    public static void sendSuccessMessage(Command command, String username, PluginApi api) {
        EsObject message = buildSuccessMessage(command);
        sendMessage(username, message, api);
    }

    public static void sendSuccessMessage(Command command, String username, EsObject initialData, PluginApi api) {
        buildSuccessMessage(command, initialData);
        sendMessage(username, initialData, api);
    }

    public static void sendMessage(String username, EsObject message, PluginApi api) {
        api.sendPluginMessageToUser(username, message);
    }

    public static void sendEventToRoom(Command command, EsObject initialData, PluginApi api) {
        initialData.setString(Field.Command.getCode(), command.getCode());
        initialData.setString(Field.Type.getCode(), Field.Event.getCode());
        sendMessageToRoom(initialData, api);
    }

    public static void sendMessageToRoom(EsObject message, PluginApi api) {
        api.sendPluginMessageToRoom(api.getZoneId(), api.getRoomId(), message);
    }

}
