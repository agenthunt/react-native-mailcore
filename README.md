# react-native-mailcore

react native bindings for https://github.com/MailCore/mailcore2

[![npm version](https://img.shields.io/npm/v/react-native-mailcore.svg?style=flat-square)](https://www.npmjs.com/package/agenthunt/react-native-mailcore)
[![npm downloads](https://img.shields.io/npm/dm/react-native-mailcore.svg?style=flat-square)](https://www.npmjs.com/package/react-native-mailcore)

## Stability status: alpha

## Setup

* `yarn add react-native-mailcore`
* `react-native link react-native-mailcore`
* For ios, setup pods for your project. Go to ios directory in your project. See https://github.com/MailCore/mailcore2/blob/master/build-mac/README.md#cocoapods

  * If you havent setup pods for your project run `pod init` in your ios directory.
  * Add `pod 'mailcore2-ios'` to your Podfile. Example

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

  * `pod install`

* For android,

  * copy paste the following lines in to `settings.gradle`

  ```
  include ':mailcore2-android-4'
  project(':mailcore2-android-4').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-mailcore/mailcore2-android-4')
  ```

  * Add the following code to `app/build.gradle` of your app.

    * For android tools version `com.android.tools.build:gradle:2.2.3`

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

      * Make sure to change the react-native version properly

    * For android tools version `com.android.tools.build:gradle:2.3.3`
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

* Send mail

```javascript
import MailCore from 'react-native-mailcore';

MailCore.sendMail({
  hostname: 'smtp.gmail.com',
  port: 465,
  username: '<gmail id>',
  password: '<password>',
  from: {
    addressWithDisplayName: 'From Label',
    mailbox: '<from email>'
  },
  to: {
    addressWithDisplayName: 'To Label',
    mailbox: '<to email>'
  },
  subject: 'Testing RN MailCore' + new Date(),
  htmlBody: `<h1> How is it going </h1>
              <p> Test message </p>
            `
})
  .then(result => {
    alert(result.status);
  })
  .catch(error => {
    alert(error);
  });
```
  * Login smtp
  ```javascript
  MailCore.loginSmtp({
    hostname: 'smtp.gmail.com',
    port: 465,
    username: 'email@gmail.com',
    password: 'password',
  }).then(result => {
    alert(result.status);
  })
  .catch(error => {
    alert(error);
  });
  ```
  * Login imap
  ```javascript
  MailCore.loginImap({
      hostname: 'imap.gmail.com',
      port: 993,
      username: 'email@gmail.com',
      password: 'password',
    }).then(result => {
      alert(result.status);
    })
    .catch(error => {
      alert(error);
    });
```
  * Note: For any of the following methods you must first use loginImap
  * Create folder
```javascript
  MailCore.createFolder({
    folder: "newfoldername"
  }).then(result => {
    alert(result.status);
  })
  .catch(error => {
    alert(error);
  });
  ```

  * Rename folder
  ```javascript
  MailCore.renameFolder({
    folderOldName: "oldFolderName",
    folderNewName: "newFolderName"
  }).then(result => {
    alert(result.status);
  })
  .catch(error => {
    alert(error);
  });
  ```

  * Delete folder
```javascript
  MailCore.deleteFolder({
    folder: "folderName"
  }).then(result => {
    alert(result.status);
  })
  .catch(error => {
    alert(error);
  });

```
  * List folders
  ```javascript
  MailCore.getFolders()
  .then(result => {
    const a = [...result.folders];
    a.forEach(element => {
      alert(element.path);
    });
  })
  .catch(error => {
      alert(error);
  });

```
## TODO

* [x] sendMail API support
* [x] createFolder API support for android
* [x] renameFolder API support for android
* [x] deleteFolder API support for android
* [x] listFolders API support for android
* [x] imapLogin API support for android
* [x] smtpLogin API support for android
* [ ] createFolder API support for ios
* [ ] renameFolder API support for ios
* [ ] deleteFolder API support for ios
* [ ] listFolders API support for ios
* [ ] imapLogin API support for ios
* [ ] smtpLogin API support for ios
* [ ] CopyEmail API support
* [ ] MoveEmail API support
* [ ] DeleteEmail API support
* [ ] SendEmail with attachments API support
* [ ] GetEmail API support
* [ ] GetEmails API support
* [ ] addFlags API support
* [ ] deleteFlags API support
* [ ] Expose other methods from libmailcore2 library
