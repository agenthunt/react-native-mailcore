
package com.reactlibrary;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.libmailcore.Address;
import com.libmailcore.AuthType;
import com.libmailcore.ConnectionType;
import com.libmailcore.MailException;
import com.libmailcore.MessageBuilder;
import com.libmailcore.MessageHeader;
import com.libmailcore.OperationCallback;
import com.libmailcore.SMTPOperation;
import com.libmailcore.SMTPSession;

import java.util.ArrayList;

public class RNMailCoreModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;

  public RNMailCoreModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
    this.mailClient = new MailClient();
  }

  @Override
  public String getName() {
    return "RNMailCore";
  }

  @ReactMethod
  public void sendMail(final ReadableMap obj, final Promise promise) {
    getCurrentActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        SMTPSession smtpSession = new SMTPSession();
        smtpSession.setHostname(obj.getString("hostname"));
        smtpSession.setPort(obj.getInt("port"));
        smtpSession.setUsername(obj.getString("username"));
        smtpSession.setPassword(obj.getString("password"));
        smtpSession.setAuthType(AuthType.AuthTypeSASLPlain);
        smtpSession.setConnectionType(ConnectionType.ConnectionTypeTLS);

        ReadableMap fromObj = obj.getMap("from");
        Address fromAddress = new Address();
        fromAddress.setDisplayName(fromObj.getString("addressWithDisplayName"));
        fromAddress.setMailbox(fromObj.getString("mailbox"));

        ReadableMap toObj = obj.getMap("to");
        Address toAddress = new Address();
        toAddress.setDisplayName(toObj.getString("addressWithDisplayName"));
        toAddress.setMailbox(toObj.getString("mailbox"));

        ArrayList<Address> toAddressList = new ArrayList();
        toAddressList.add(toAddress);

        MessageHeader messageHeader = new MessageHeader();
        messageHeader.setSubject(obj.getString("subject"));
        messageHeader.setTo(toAddressList);
        messageHeader.setFrom(fromAddress);

        MessageBuilder messageBuilder = new MessageBuilder();
        messageBuilder.setHeader(messageHeader);
        messageBuilder.setHTMLBody(obj.getString("htmlBody"));

        SMTPOperation smtpOperation = smtpSession.sendMessageOperation(fromAddress, toAddressList, messageBuilder.data());
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
    });
  }

  @ReactMethod
  public void loginImap(final ReadableMap obj, final Promise promise){
    getCurrentActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        UserCredential user = new UserCredential(obj);
        mailClient.initIMAPSession(user,promise);
      }
    });
  }

  @ReactMethod
  public void loginSmtp(final ReadableMap obj, final Promise promise){
    getCurrentActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        UserCredential user = new UserCredential(obj);
        mailClient.initSMTPSession(user,promise);
      }
    });
  }

  @ReactMethod
  public void sendMail(final ReadableMap obj, final Promise promise){
    getCurrentActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        //MailClient.sendMail(new SendMailData(obj), promise);
      }
    });
  }

  @ReactMethod
  public void createFolder(final ReadableMap obj,final Promise promise) {
    getCurrentActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        mailClient.createFolderLabel(obj,promise);
      }
    });
  }

  @ReactMethod
  public void renameFolder(final ReadableMap obj,final Promise promise) {
    getCurrentActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        mailClient.renameFolderLabel(obj,promise);
      }
    });
  }

  @ReactMethod
  public void deleteFolder(final ReadableMap obj,final Promise promise) {
    getCurrentActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        mailClient.deleteFolderLabel(obj,promise);
      }
    });
  }
  
  @ReactMethod
  public void getFolders(final Promise promise) {
    getCurrentActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        mailClient.getFolders(promise);
      }
    });
  }
}
