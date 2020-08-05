# react-native-mailcore

react native bindings for https://github.com/MailCore/mailcore2

[![npm version](https://img.shields.io/npm/v/react-native-mailcore.svg?style=flat-square)](https://www.npmjs.com/package/agenthunt/react-native-mailcore)
[![npm downloads](https://img.shields.io/npm/dm/react-native-mailcore.svg?style=flat-square)](https://www.npmjs.com/package/react-native-mailcore)

## Stability status: alpha

## Setup

- `yarn add react-native-mailcore`
- `react-native link react-native-mailcore`
- For ios, setup pods for your project. Go to ios directory in your project. See https://github.com/MailCore/mailcore2/blob/master/build-mac/README.md#cocoapods

  - If you havent setup pods for your project run `pod init` in your ios directory.
  - Add `pod 'mailcore2-ios'` to your Podfile. Example

    ```
      # Uncomment the next line to define a global platform for your project
      # platform :ios, '9.0'

      target 'BasicExample' do
        # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
        # use_frameworks!

        # Pods for BasicExample

        pod 'mailcore2-ios'

        target 'BasicExampleTests' do
          inherit! :search_paths
          # Pods for testing
        end

      end

      target 'BasicExample-tvOS' do
        # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
        # use_frameworks!

        # Pods for BasicExample-tvOS

        target 'BasicExample-tvOSTests' do
          inherit! :search_paths
          # Pods for testing
        end

      end
    ```

  - `pod install`

- For android,

  - copy paste the following lines in to `settings.gradle`

  ```
  include ':mailcore2-android-4'
  project(':mailcore2-android-4').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-mailcore/mailcore2-android-4')
  ```

  - Add the following code to `app/build.gradle` of your app.

    - For android tools version `com.android.tools.build:gradle:2.2.3`

      ```
        import com.android.build.gradle.internal.pipeline.TransformTask

        def deleteDuplicateJniFiles() {
            def files = fileTree("${buildDir}/intermediates/exploded-aar/com.facebook.react/react-native/0.43.3/jni/") {
                include "**/libgnustl_shared.so"
            }
            files.each { it.delete() }
        }

        tasks.withType(TransformTask) { pkgTask ->
            pkgTask.doFirst { deleteDuplicateJniFiles() }
        }
      ```

      - Make sure to change the react-native version properly

    - For android tools version `com.android.tools.build:gradle:2.3.3`
      ```
      android {
        ...
        ...
        ...
        ...
        ...
          packagingOptions{
              pickFirst '**/libgnustl_shared.so'
          }
      }
      ```

## Usage

- Note: For any of the following methods you must first use loginImap
- Note: For SendMail method you must first use loginSmtp
- Note: For the use of attachments download remember to give permission to the application

```javascript
import MailCore from "react-native-mailcore";
```

- Login smtp

```javascript
MailCore.loginSmtp({
  hostname: "smtp.gmail.com",
  port: 465,
  username: "email@gmail.com",
  password: "password",
})
  .then((result) => {
    alert(result.status);
  })
  .catch((error) => {
    alert(error);
  });
```

- Login imap

```javascript
MailCore.loginImap({
  hostname: "imap.gmail.com",
  port: 993,
  username: "email@gmail.com",
  password: "password",
})
  .then((result) => {
    alert(result.status);
  })
  .catch((error) => {
    alert(error);
  });
```

- Create Folder

```javascript
MailCore.createFolder({
  folder: "newfoldername",
})
  .then((result) => {
    alert(result.status);
  })
  .catch((error) => {
    alert(error);
  });
```

- List folders

```javascript
MailCore.getFolders()
  .then((result) => {
    const a = [...result.folders];
    a.forEach((element) => {
      alert(element.path);
    });
  })
  .catch((error) => {
    alert(error);
  });
```

- Move Email

```javascript
MailCore.moveEmail({
  folderFrom: "oldfolder",
  messageId: 14,
  folderTo: "newfolder",
})
  .then((result) => {
    alert(result.status);
  })
  .catch((error) => {
    alert(error);
  });
```

- Permant Email Delete

```javascript
MailCore.permantDeleteEmail({
  folderFrom: "folder",
  messageId: messageId,
})
  .then((result) => {
    alert(result.status);
  })
  .catch((error) => {
    alert(error);
  });
```

- Action Flag Message

```javascript
  MailCore.actionFlagMessage({
    folder: 'folder',
    messageId: messageId,
    flagsRequestKind: <FlagsRequestKind val int>,
    messageFlag: <MessageFlag val int>
  })
  .then(result => {
      alert(result.status);
  })
  .catch(error => {
      alert(error);

  });
```

- Action label Message

```javascript
    MailCore.actionLabelMessage({
      folder: 'folder',
      messageId: messageId,
      flagsRequestKind: <FlagsRequestKind val int>,
      tags: ["tag1","tag2","tag3"]
    })
    .then(result => {
        alert(result.status);
    })
    .catch(error => {
        alert(error);
    });
```

- Rename folder

```javascript
MailCore.renameFolder({
  folderOldName: "oldFolderName",
  folderNewName: "newFolderName",
})
  .then((result) => {
    alert(result.status);
  })
  .catch((error) => {
    alert(error);
  });
```

- Delete folder

```javascript
MailCore.deleteFolder({
  folder: "folderName",
})
  .then((result) => {
    alert(result.status);
  })
  .catch((error) => {
    alert(error);
  });
```

- List folders

```javascript
MailCore.getFolders()
  .then((result) => {
    const a = [...result.folders];
    a.forEach((element) => {
      alert(element.path);
    });
  })
  .catch((error) => {
    alert(error);
  });
```

- Move Email

```javascript
MailCore.moveEmail({
  folderFrom: "oldfolder",
  messageId: 14,
  folderTo: "newfolder",
})
  .then((result) => {
    alert(result.status);
  })
  .catch((error) => {
    alert(error);
  });
```

- Permant Email Delete

```javascript
MailCore.permantDeleteEmail({
  folderFrom: "folder",
  messageId: messageId,
})
  .then((result) => {
    alert(result.status);
  })
  .catch((error) => {
    alert(error);
  });
```

- Action Flag Message

```javascript
  MailCore.actionFlagMessage({
    folder: 'folder',
    messageId: messageId,
    flagsRequestKind: <FlagsRequestKind val int>,
    messageFlag: <MessageFlag val int>
  })
  .then(result => {
      alert(result.status);
  })
  .catch(error => {
      alert(error);

  });
```

- Action label Message

```javascript
  MailCore.actionLabelMessage({
    folder: 'folder',
    messageId: messageId,
    flagsRequestKind: <FlagsRequestKind val int>,
    tags: ["tag1","tag2","tag3"]
  })
  .then(result => {
      alert(result.status);
  })
  .catch(error => {
      alert(error);
  });
```

- Send Mail

```javascript
MailCore.sendMail({
  headers: {
    key: "value",
  },
  from: {
    addressWithDisplayName: "from label",
    mailbox: "email@gmail.com",
  },
  to: {
    "email@gmail.com": "to label",
    "email@email.com": "to label",
  },
  cc: {
    "email@gmail.com": "cc label",
    "email@email.com": "cc label",
  },
  bcc: {
    "email@gmail.com": "bcc label",
    "email@email.com": "bcc label",
  },
  subject: "subject",
  body: "body",
  attachments: ["url/filename", "url/filename"],
})
  .then((result) => {
    alert(result.status);
  })
  .catch((error) => {
    alert(error);
  });
```

- Get mail

```javascript
  MailCore.getMail({
  folder: 'folder',
  messageId: messageId,
  requestKind: <IMAPMessagesRequestKind val int>
  })
  .then(result => {
    let mail = {
      id: result.id,
      date: result.date,
      from: result.from,
      to: result.to,
      cc: result.cc,
      bcc: result.bcc,
      subject: result.subject,
      body: result.body,
      attachments: result.attachments
    }
    alert(result.status);
    console.log(mail)
  })
  .catch(error => {
      alert(error);
  });
```

- Get Attachment

```javascript
MailCore.getAttachment({
  filename: "filename",
  folder: "folder",
  messageId: messageId,
  partID: "partID",
  encoding: encoding,
  folderOutput: "urlOutput",
})
  .then((result) => {
    alert(result.status);
  })
  .catch((error) => {
    alert(error);
  });
```

    * Get Attachment Inline (Android)
    * In IOS the inline attachment comes in the getmail mail method

```javascript
MailCore.getAttachmentInline({
  filename: "filename",
  folder: "folder",
  messageId: messageId,
  partID: "partID",
  encoding: encoding,
  mimepart: "image/png",
})
  .then((result) => {
    alert(result.status);
  })
  .catch((error) => {
    alert(error);
  });
```

- List mails

```javascript
  MailCore.getMails({
    folder: 'folder',
    requestKind: <IMAPMessagesRequestKind int value>
  })
  .then(result => {
    let promises = [];
    for (let i=0; i<result.mails.length;i++) {
      let mail = result.mails[i];
      let promise = new Promise((resolve,reject) => {
        MailCore.getMail({
          folder: 'folder',
          messageId: mail.id,
          requestKind: <IMAPMessagesRequestKind int value>
          }).then(mailDetails => {
            mail.body = mailDetails.body
            resolve(mail);
          })
          .catch(error => reject(error))
      });
      promises.push(promise)
    }
    Promise.all(promises)
    .then(mails =>
      console.log(mails))
  })
  .catch(error => {
      alert(error);
  });
}
```

## TODO

- [x] createFolder API support
- [x] renameFolder API support
- [x] deleteFolder API support
- [x] listFolders API support
- [x] imapLogin API support
- [x] smtpLogin API support
- [x] GetEmail API support
- [x] MoveEmail API support
- [x] DeleteEmail API support
- [x] Download attachment
- [x] SendEmail with attachments
- [x] addFlags API support
- [x] deleteFlags API support
- [x] GetEmails API support
- [x] Basic Example
