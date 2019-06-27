package com.reactlibrary;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.WritableNativeArray;

import com.libmailcore.Address;
import com.libmailcore.AuthType;
import com.libmailcore.ConnectionType;
import com.libmailcore.MailException;
import com.libmailcore.MessageBuilder;
import com.libmailcore.MessageHeader;
import com.libmailcore.OperationCallback;
import com.libmailcore.SMTPOperation;
import com.libmailcore.SMTPSession;
import com.libmailcore.IMAPSession;
import com.libmailcore.IMAPOperation;
import com.libmailcore.IMAPFetchContentOperation;
import com.libmailcore.IMAPFetchFoldersOperation;
import com.libmailcore.IMAPFetchMessagesOperation;
import com.libmailcore.IMAPFetchParsedContentOperation;
import com.libmailcore.IMAPFolder;
import java.util.ArrayList;
import java.util.List;

public class MailClient {

    public SMTPSession smtpSession;
    public IMAPSession imapSession;

    public void initIMAPSession(UserCredential userCredential,final Promise promise){
        this.imapSession = new IMAPSession();
        imapSession.setHostname(userCredential.getHostname());
        imapSession.setPort(userCredential.getPort());
        imapSession.setUsername(userCredential.getUsername());
        imapSession.setPassword(userCredential.getPassword());
        imapSession.setAuthType(AuthType.AuthTypeSASLPlain);
        imapSession.setConnectionType(ConnectionType.ConnectionTypeTLS);
        IMAPOperation imapOperation = this.imapSession.checkAccountOperation();
        imapOperation.start(new OperationCallback() {
            @Override
            public void succeeded() {
                WritableMap result = Arguments.createMap();
                result.putString("status", "SUCCESS");
                promise.resolve(result);
            }
            @Override
            public void failed(MailException e) {
                promise.reject(String.valueOf(e.errorCode()), e.getMessage());
            }
        });
    }

    public void initSMTPSession(UserCredential userCredential,final Promise promise){
        this.smtpSession = new SMTPSession();
        smtpSession.setHostname(userCredential.getHostname());
        smtpSession.setPort(userCredential.getPort());
        smtpSession.setUsername(userCredential.getUsername());
        smtpSession.setPassword(userCredential.getPassword());
        smtpSession.setAuthType(AuthType.AuthTypeSASLPlain);
        smtpSession.setConnectionType(ConnectionType.ConnectionTypeTLS);
        SMTPOperation smtpOperation = this.smtpSession.loginOperation();
        smtpOperation.start(new OperationCallback() {
            @Override
            public void succeeded() {
                WritableMap result = Arguments.createMap();
                result.putString("status", "SUCCESS");
                promise.resolve(result);
            }
            @Override
            public void failed(MailException e) {
                promise.reject(String.valueOf(e.errorCode()), e.getMessage());
            }
        });
    } 


    public void createFolderLabel(final ReadableMap obj,final Promise promise) {
        IMAPOperation imapOperation = this.imapSession.createFolderOperation(obj.getString("folder"));
        imapOperation.start(new OperationCallback() {
            @Override
            public void succeeded() {
                WritableMap result = Arguments.createMap();
                result.putString("status", "SUCCESS");
                promise.resolve(result);
            }
            @Override
            public void failed(MailException e) {
                promise.reject(String.valueOf(e.errorCode()), e.getMessage());
            }
        });
    }

    public void renameFolderLabel(final ReadableMap obj,final Promise promise) {
        IMAPOperation imapOperation = this.imapSession.renameFolderOperation(obj.getString("folderOldName"),obj.getString("folderNewName"));
        imapOperation.start(new OperationCallback() {
            @Override
            public void succeeded() {
                WritableMap result = Arguments.createMap();
                result.putString("status", "SUCCESS");
                promise.resolve(result);
            }
            @Override
            public void failed(MailException e) {
                promise.reject(String.valueOf(e.errorCode()), e.getMessage());
            }
        });
    }

    public void deleteFolderLabel(final ReadableMap obj,final Promise promise) {
        IMAPOperation imapOperation = this.imapSession.deleteFolderOperation(obj.getString("folder"));
        imapOperation.start(new OperationCallback() {
            @Override
            public void succeeded() {
                WritableMap result = Arguments.createMap();
                result.putString("status", "SUCCESS");
                promise.resolve(result);
            }
            @Override
            public void failed(MailException e) {
                promise.reject(String.valueOf(e.errorCode()), e.getMessage());
            }
        });
    }

    public void getFolders(final Promise promise) {
        final IMAPFetchFoldersOperation foldersOperation = imapSession.fetchAllFoldersOperation();
        foldersOperation.start(new OperationCallback() {
            @Override
            public void succeeded() {
                List<IMAPFolder> folders = foldersOperation.folders();
                WritableMap result = Arguments.createMap();
                WritableArray a = new WritableNativeArray();
                result.putString("status", "SUCCESS");
                for (IMAPFolder folder : folders) {
                    WritableMap mapFolder = Arguments.createMap();
                        mapFolder.putString("path",folder.path());
                        mapFolder.putInt("flags", folder.flags());
                        a.pushMap(mapFolder);    
                }
                result.putArray("folders",a);
                promise.resolve(result);
            }
            @Override
            public void failed(MailException e) {
                promise.reject(String.valueOf(e.errorCode()), e.getMessage());
            }
        });
    }
}
