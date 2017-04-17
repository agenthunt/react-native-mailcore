
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
  }

  @Override
  public String getName() {
    return "RNMailCore";
  }

  @ReactMethod
  public void sendMail(final ReadableMap obj, final Promise promise){
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

        MessageHeader messageHeader = new MessageHeader();
        messageHeader.setSubject(obj.getString("subject"));

        MessageBuilder messageBuilder = new MessageBuilder();
        messageBuilder.setHeader(messageHeader);
        messageBuilder.setHTMLBody(obj.getString("htmlBody"));

        ArrayList<Address> toAddressList = new ArrayList();
        toAddressList.add(toAddress);

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
}