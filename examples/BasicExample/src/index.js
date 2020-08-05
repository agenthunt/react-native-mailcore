import React, { Component } from 'react';
import { Alert, AppRegistry, Button, StyleSheet, View } from 'react-native';
import MailCore from 'react-native-mailcore';
import * as FlagsRequestKind from './constants/FlagsRequestKind';
import * as IMAPMessagesRequestKind from './constants/IMAPMessagesRequestKind';
import * as MessageFlag from './constants/MessageFlag';
import * as Connection from './constants/Connection';

export default class BasicExample extends Component {
  _onPressButton() {
    Alert.alert('You tapped the button!')
  }

  loginImap() {
    MailCore.loginImap({
      hostname: Connection.TEST_IMAP_HOSTNAME,
      port: Connection.TEST_PORT_IMAP,
      username: Connection.TEST_USERNAME,
      password: Connection.TEST_PASSWORD,
    }).then(result => {
      alert(result.status);
    })
    .catch(error => {
      alert(error);
    });
  }

  loginSmtp() {
    MailCore.loginSmtp({
      hostname: Connection.TEST_SMTP_HOSTNAME,
      port: Connection.TEST_PORT_STMP,
      username: Connection.TEST_USERNAME,
      password: Connection.TEST_PASSWORD,
    }).then(result => {
      alert(result.status);
    })
    .catch(error => {
      alert(error);
    });
  }

  createFolder() {
    MailCore.createFolder({
      folder: "newfolder"
    }).then(result => {
      alert(result.status);
    })
    .catch(error => {
      alert(error);
    });
  }

  deleteFolder() {
    MailCore.deleteFolder({
      folder: "changedNameFolder"
    }).then(result => {
      alert(result.status);
    })
    .catch(error => {
      alert(error);
    });
  } 

  renameFolder() {
    MailCore.renameFolder({
      folderOldName: "newfolder",
      folderNewName: "changedNameFolder"
    }).then(result => {
      alert(result.status);
    })
    .catch(error => {
      alert(error);
    });
  }

  getFolders() {
    MailCore.getFolders()
    .then(result => {
      console.log(result);
    })
    .catch(error => {
        alert(error);
    });
  }

  moveEmail() {
    MailCore.moveEmail({
      folderFrom: "INBOX",
      messageId: 18,
      folderTo: "test"
    })
    .then(result => {
      alert(result.status);
    })
    .catch(error => {
        alert(error);
    });
  }

  permantDeleteEmail() {
    MailCore.permantDeleteEmail({
      folderFrom: "INBOX",
      messageId: 18
    })
    .then(result => {
        alert(result.status);
    })
    .catch(error => {
        alert(error);
    });
  }

  flagMessage() {
    MailCore.actionFlagMessage({
      folder: "INBOX",
      messageId: 17,
      flagsRequestKind: FlagsRequestKind.ADD,
      messageFlag: MessageFlag.SEEN
    })
    .then(result => {
        alert(result.status);
    })
    .catch(error => {
        alert(error);
    });
  }

  labelMessage() {
    const m = new Map()
    m.set([0, 'red'], [1, 'blue'], [2, 'yellow'], [3, 'orange'])
    MailCore.actionLabelMessage({
      folder: "INBOX",
      messageId: 17,
      flagsRequestKind: FlagsRequestKind.ADD,
      tags: ["one","two","three"]
    })
    .then(result => {
        alert(result.status);
    })
    .catch(error => {
        alert(error);
    });
  }

  sendMail() {
    alert(new Date());
    let subject = "this is subject mail"
    let body = "<div>New body for new email<blockquote>this quote</blockquote></div>"
    MailCore.sendMail({
      headers: {
        isEncrypted: "true"
      },
      from: {
        addressWithDisplayName: 'Marcos Prosperi',
        mailbox: 'email@gmail.com'
      },
      to: {
        "test2@mail.com.ar": 'Loren Ipsun',
        "test1@gmail.com": 'Ipsun Loren',
        "test@gmail.com": 'Mail test account'
      },
      cc: {
        "test@gmail.com": 'name lastname',
        "test@gmail.com": 'name lastname'
      },
      bcc: {
        "test@gmail.com": 'name lastname',
        "test@gmail.com": 'name lastname'
      },
      subject: subject,
      body: body,
      attachments: ["eso ya se vio.jpg","GOOGLE.JPG","IMG_0007.JPG"]
    })
    .then(result => {
        alert(result.status);
    })
    .catch(error => {
        alert(error);
    });
  }



  getMail() {
    let requestKind = IMAPMessagesRequestKind.HEADERS | IMAPMessagesRequestKind.STRUCTURE | IMAPMessagesRequestKind.INTERNAL_DATE | 
    IMAPMessagesRequestKind.HEADER_SUBJECT | IMAPMessagesRequestKind.FLAGS | IMAPMessagesRequestKind.EXTRA_HEADERS
    MailCore.getMail({
      folder: "INBOX",
      messageId: 22,
      requestKind: requestKind,
      headers: ['isEncrypted']
    })
    .then(result => { 
      alert("getMail then");
      console.log(result);
    })
    .catch(error => {
        alert(error);
    });
  }

  getAttachment() {
    let requestKind = IMAPMessagesRequestKind.HEADERS | IMAPMessagesRequestKind.STRUCTURE | IMAPMessagesRequestKind.INTERNAL_DATE | 
    IMAPMessagesRequestKind.HEADER_SUBJECT | IMAPMessagesRequestKind.FLAGS | IMAPMessagesRequestKind.EXTRA_HEADERS;
    MailCore.getAttachment({
      filename: "eso ya se vio.jpg",
      folder: "INBOX",
      messageId: 18,
      partID: "3",
      encoding: 3,
      folderOutput: "/storage/emulated/0/directoryDrop/",
      requestKind: requestKind
    })
    .then(result => {
      console.log(result);
    })
    .catch(error => {
        alert(error);
    });
  }


  getMails() {
    let requestKind = IMAPMessagesRequestKind.HEADERS | IMAPMessagesRequestKind.STRUCTURE | 
      IMAPMessagesRequestKind.INTERNAL_DATE | IMAPMessagesRequestKind.HEADER_SUBJECT | 
      IMAPMessagesRequestKind.FLAGS | IMAPMessagesRequestKind.EXTRA_HEADERS | 
      IMAPMessagesRequestKind.GMAIL_MESSAGE_ID | IMAPMessagesRequestKind.GMAIL_THREAD_ID;
    let folder = "INBOX";
    MailCore.getMailsByRange({
      folder: folder,
      requestKind: requestKind,
      from: 1,
      length: 73,
      headers: ['isEncrypted']
    })
    .then(result => {
      alert(result.mails.length);
      console.log(result);
    })
    .catch(error => {
        alert(error);
    });
  }

  render() {  
    return (
      <View style={styles.container}>
        <View style={styles.buttonContainer}>
          <Button
            onPress={this.loginImap}
            title="Test Login Imap"
          />
                <Button
            onPress={this.loginSmtp}
            title="Test Login smtp"
            color="#841584"
          />
        </View>
        <View >
          <Button 
            onPress={this.createFolder}
            title="Create folder"
          />
            <Button 
            onPress={this.renameFolder}
            title="Rename Folder"
          />
            <Button 
            onPress={this.deleteFolder}
            title="Delete Folder"
          />
        
        
          <Button 
            onPress={this.getFolders}
            title="List Folders"
          />
        
        
        <Button 
            onPress={this.sendMail}
            title="Send Email"
          />
        <Button 
            onPress={this.moveEmail}
            title="Move Email"
          />
          <Button 
            onPress={this.permantDeleteEmail}
            title="Permant Delete"
          />
          <Button 
            onPress={this.getMail}
            title="getMail"
          />
          <Button 
            onPress={this.getMails}
            title="getMails"
          />
          <Button 
            onPress={this.getAttachment}
            title="getAttachment"
          />
        
          <Button 
            onPress={this.flagMessage}
            title="Actions Flag Message"
          />
          <Button 
            onPress={this.labelMessage}
            title="Actions label Message"
          />
        </View>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
   flex: 1,
   justifyContent: 'center',
  },
  buttonContainer: {
    margin: 20
  },
  alternativeLayoutButtonContainer: {
    margin: 20,
    flexDirection: 'row',
    justifyContent: 'space-between'
  },
  item: {
    padding: 10,
    fontSize: 18,
    height: 44,
  },
  buttonStyle: {
    marginBottom: 5,
  }
});

AppRegistry.registerComponent('BasicExample', () => BasicExample);
