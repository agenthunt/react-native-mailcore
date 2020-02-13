
package com.reactlibrary;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;

public class RNMailCoreModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;
  private final MailClient mailClient;

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
  
  @ReactMethod
  public void moveEmail(final ReadableMap obj, final Promise promise) {
    getCurrentActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        mailClient.moveEmail(obj,promise);
      }
    });
  }

  @ReactMethod
  public void permantDeleteEmail(final ReadableMap obj, final Promise promise) {
    getCurrentActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        mailClient.permantDelete(obj, promise);
      }
    });
  }

  @ReactMethod
  public void actionFlagMessage(final ReadableMap obj, final Promise promise) {
    getCurrentActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        mailClient.ActionFlagMessage(obj, promise);
      }
    });
  }

  @ReactMethod
  public void actionLabelMessage(final ReadableMap obj, final Promise promise) {
    getCurrentActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        mailClient.ActionLabelMessage(obj, promise);
      }
    });
  }

  @ReactMethod
  public void sendMail(final ReadableMap obj, final Promise promise) {
      mailClient.sendMail(obj, promise, getCurrentActivity());
  }

  @ReactMethod
  public void getMail(final ReadableMap obj, final Promise promise) {
    getCurrentActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        mailClient.getMail(obj, promise);
      }
    });
  }

@ReactMethod
  public void getAttachment(final ReadableMap obj, final Promise promise) {
    getCurrentActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        mailClient.getAttachment(obj, promise);
      }
    });
  }

   @ReactMethod
    public void getAttachmentInline(final ReadableMap obj, final Promise promise) {
        getCurrentActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mailClient.getAttachmentInline(obj, promise);
            }
        });
    }

  @ReactMethod
  public void getMails(final ReadableMap obj, final Promise promise) {
    getCurrentActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        mailClient.getMails(obj, promise);
      }
    });
  }

  @ReactMethod
  public void getMailsThread(final ReadableMap obj, final Promise promise) {
    getCurrentActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        mailClient.getMailsThread(obj, promise);
      }
    });
  }

  @ReactMethod
  public void statusFolder(final ReadableMap obj, final Promise promise) {
    getCurrentActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        mailClient.statusFolder(obj,promise);
      }
    });
  }

  @ReactMethod
  public void getMailsByRange(final ReadableMap obj, final Promise promise) {
    getCurrentActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        mailClient.getMailsByRange(obj,promise);
      }
    });
  }

  @ReactMethod
  public void getMailsByThread(final ReadableMap obj, final Promise promise) {
    getCurrentActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        mailClient.getMailsByThread(obj,promise);
      }
    });
  }

}