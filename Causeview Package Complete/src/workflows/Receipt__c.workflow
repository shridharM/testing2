<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Receipt_Email_Send</fullName>
        <description>Receipt Email Send</description>
        <protected>false</protected>
        <recipients>
            <field>Receipt_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Giving_Power/Receipt_Template_2</template>
    </alerts>
    <alerts>
        <fullName>SendConsolidatedEmailReceipt</fullName>
        <description>SendConsolidatedEmailReceipt</description>
        <protected>false</protected>
        <recipients>
            <field>Receipt_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Giving_Power/Consolidated_Receipt_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>SendEventRegistrationEmailReceipt</fullName>
        <description>SendEventRegistrationEmailReceipt</description>
        <protected>false</protected>
        <recipients>
            <field>Receipt_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Giving_Power/Event_Registration_Acknowledgement</template>
    </alerts>
    <alerts>
        <fullName>SendReceiptEmail</fullName>
        <description>SendReceiptEmail</description>
        <protected>false</protected>
        <recipients>
            <field>Receipt_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Giving_Power/Receipt_Template_2</template>
    </alerts>
    <fieldUpdates>
        <fullName>DateIssued</fullName>
        <description>Assign the date Issued to the receipt</description>
        <field>Date_Issued__c</field>
        <formula>TODAY()</formula>
        <name>DateIssued</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Issued</fullName>
        <description>Changes the recordtype to Issued</description>
        <field>RecordTypeId</field>
        <lookupValue>Issued</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Issued</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Receipt_to_Issued</fullName>
        <description>Sets receipt record type to Issued (read-only).</description>
        <field>RecordTypeId</field>
        <lookupValue>Issued</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Receipt to Issued</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetStatustoIssued</fullName>
        <description>Sets Receipt Status to Issued</description>
        <field>Status__c</field>
        <literalValue>Issued</literalValue>
        <name>SetStatustoIssued</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateAmountNotEligible</fullName>
        <description>Populates Amount Not Eligible with Sponsorship/Benefit Amount</description>
        <field>Amount_Not_Eligible__c</field>
        <formula>Gift__r.Sponsorship_Amount__c</formula>
        <name>UpdateAmountNotEligible</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateReceiptAddress_Org</fullName>
        <description>Updates receipt address field with Organization&apos;s address.</description>
        <field>Receipt_Address__c</field>
        <formula>Gift__r.Organization__r.BillingStreet   &amp; BR()
&amp; Gift__r.Organization__r.BillingCity &amp; &quot;, &quot; &amp; Gift__r.Organization__r.BillingState &amp; &quot; &quot; &amp; Gift__r.Organization__r.BillingPostalCode &amp; &quot; &quot; &amp; Gift__r.Organization__r.BillingCountry</formula>
        <name>UpdateReceiptAddress (Org)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateReceiptEmailAddress</fullName>
        <description>Updates receipt email address field with individual or organization email address for send.</description>
        <field>Receipt_Email_Address__c</field>
        <formula>IF(ISBLANK(Organization__c),  Constituent__r.Email,  Organization__r.Email__c)</formula>
        <name>UpdateReceiptEmailAddress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateReceiptLetterTxt2</fullName>
        <description>Updates Letter - Text Block field with Plain text value from Letter.</description>
        <field>Letter_Text_Block__c</field>
        <formula>Gift__r.Letter__r.Body_Text_Block_Plain_Text__c</formula>
        <name>UpdateReceiptLetterTxt</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateReceiptName_Org</fullName>
        <description>Updates receipt name with Organization&apos;s name.</description>
        <field>Receipt_Name__c</field>
        <formula>Gift__r.Organization__r.Name</formula>
        <name>UpdateReceiptName (Org)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateTransactionAcknowledged</fullName>
        <description>Update Transaction status to acknowledged</description>
        <field>Status__c</field>
        <literalValue>Acknowledged</literalValue>
        <name>UpdateTransactionAcknowledged</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Gift__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Receipt_Address</fullName>
        <description>Captures receipt address from Account record.</description>
        <field>Receipt_Address__c</field>
        <formula>Gift__r.Constituent__r.MailingStreet &amp; BR()
&amp; Gift__r.Constituent__r.MailingCity &amp; &quot;, &quot; &amp; Gift__r.Constituent__r.MailingState &amp; &quot; &quot; &amp; Gift__r.Constituent__r.MailingPostalCode</formula>
        <name>Update Receipt Address</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Receipt_City</fullName>
        <description>Update the city on the receipt</description>
        <field>Receipt_City__c</field>
        <formula>Gift__r.Constituent__r.MailingCity</formula>
        <name>Update Receipt City</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Receipt_City_Org</fullName>
        <description>Updates the City on the Receipt with the Organization</description>
        <field>Receipt_City__c</field>
        <formula>Gift__r.Organization__r.BillingCity</formula>
        <name>Update Receipt City (Org)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Receipt_Country</fullName>
        <description>Update the Country of the Receipt</description>
        <field>Receipt_Country__c</field>
        <formula>Gift__r.Constituent__r.MailingCountry</formula>
        <name>Update Receipt Country</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Receipt_Country_Org</fullName>
        <description>Updates the receipt with the Country</description>
        <field>Receipt_Country__c</field>
        <formula>Gift__r.Organization__r.BillingCountry</formula>
        <name>Update Receipt Country (Org)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Receipt_Name</fullName>
        <description>Updates receipt name with constituent name when receipt record is created.</description>
        <field>Receipt_Name__c</field>
        <formula>IF(ISBLANK(Organization__c),(

IF(ISBLANK( Gift__r.Constituent__r.Primary_Addressee__c), 
(
IF (ISPICKVAL(Gift__r.Constituent__r.Salutation,&quot;&quot;), 
(Gift__r.Constituent__r.FirstName &amp; &quot; &quot; &amp; Gift__r.Constituent__r.LastName),
(TEXT(Gift__r.Constituent__r.Salutation) &amp; &quot; &quot; &amp;  Gift__r.Constituent__r.FirstName &amp; &quot; &quot; &amp; Gift__r.Constituent__r.LastName)
)),
Gift__r.Constituent__r.Primary_Addressee__c)),

 Organization__r.Name)</formula>
        <name>Update Receipt Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Receipt_State</fullName>
        <description>Updates the State on the Receipt</description>
        <field>Receipt_State_Province__c</field>
        <formula>Gift__r.Constituent__r.MailingState</formula>
        <name>Update Receipt State</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Receipt_State_Org</fullName>
        <description>Updates the receipt with the Organization&apos;s State</description>
        <field>Receipt_State_Province__c</field>
        <formula>Gift__r.Organization__r.BillingState</formula>
        <name>Update Receipt State (Org)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Receipt_Street</fullName>
        <description>Updates the street of the Receipt</description>
        <field>Receipt_Street__c</field>
        <formula>Gift__r.Constituent__r.MailingStreet</formula>
        <name>Update Receipt Street</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Receipt_Street_org</fullName>
        <description>Updates the street on the receipt</description>
        <field>Receipt_Street__c</field>
        <formula>Gift__r.Organization__r.BillingStreet</formula>
        <name>Update Receipt Street (Org)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Receipt_ZipCode</fullName>
        <description>Update the ZipCode of the Receipt</description>
        <field>Receipt_Zip_Postal_Code__c</field>
        <formula>Gift__r.Constituent__r.MailingPostalCode</formula>
        <name>Update Receipt ZipCode</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Receipt_ZipCode_Org</fullName>
        <description>Updates the receipt with the zip code from the</description>
        <field>Receipt_Zip_Postal_Code__c</field>
        <formula>Gift__r.Organization__r.BillingPostalCode</formula>
        <name>Update Receipt ZipCode (Org)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>IssueReceipt</fullName>
        <actions>
            <name>DateIssued</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Issued</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Receipt__c.Status__c</field>
            <operation>equals</operation>
            <value>Issued</value>
        </criteriaItems>
        <description>Changes the receipt&apos;s recordtype when the status is updated.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PopulateReceiptEmailAddress</fullName>
        <actions>
            <name>UpdateReceiptEmailAddress</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Receipt__c.Receipt_Email_Address__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Populates the Receipt Email Address field with the constituent email address for send.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Receipt Issued</fullName>
        <actions>
            <name>Receipt_to_Issued</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Receipt__c.Status__c</field>
            <operation>equals</operation>
            <value>Issued</value>
        </criteriaItems>
        <description>Changes the receipt to read-only record type when record has been issued.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SendConsolidatedReceipt</fullName>
        <actions>
            <name>SendConsolidatedEmailReceipt</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>DateIssued</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Receipt_to_Issued</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SetStatustoIssued</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Automated_Email_Receipt_Sent</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8 AND 9</booleanFilter>
        <criteriaItems>
            <field>Receipt__c.Auto_Email_Receipt__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Receipt__c.Receipt_Email_Address__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Gift__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Gift</value>
        </criteriaItems>
        <criteriaItems>
            <field>Receipt__c.Receipt_Type__c</field>
            <operation>equals</operation>
            <value>Consolidated</value>
        </criteriaItems>
        <criteriaItems>
            <field>Receipt__c.Receipt_Name__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Receipt__c.Receipt_Street__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Receipt__c.Receipt_City__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Receipt__c.Receipt_State_Province__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Receipt__c.Receipt_Zip_Postal_Code__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Auto emails consolidated gift receipt when the Auto Email Receipt box is checked off.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SendEventRegistrationReceipt</fullName>
        <actions>
            <name>SendEventRegistrationEmailReceipt</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>DateIssued</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Receipt_to_Issued</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SetStatustoIssued</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Automated_Email_Receipt_Sent</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8 AND 9</booleanFilter>
        <criteriaItems>
            <field>Receipt__c.Auto_Email_Receipt__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Receipt__c.Receipt_Email_Address__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Gift__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Event Registration</value>
        </criteriaItems>
        <criteriaItems>
            <field>Receipt__c.Receipt_Type__c</field>
            <operation>notEqual</operation>
            <value>Consolidated</value>
        </criteriaItems>
        <criteriaItems>
            <field>Receipt__c.Receipt_Name__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Receipt__c.Receipt_Street__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Receipt__c.Receipt_City__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Receipt__c.Receipt_State_Province__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Receipt__c.Receipt_Zip_Postal_Code__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Auto emails event registration receipt when the Auto Email Receipt box is checked off.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SendGiftReceipt</fullName>
        <actions>
            <name>SendReceiptEmail</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>DateIssued</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Receipt_to_Issued</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SetStatustoIssued</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Automated_Email_Receipt_Sent</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8 AND 9 AND 10</booleanFilter>
        <criteriaItems>
            <field>Receipt__c.Auto_Email_Receipt__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Receipt__c.Receipt_Email_Address__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Gift__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Gift</value>
        </criteriaItems>
        <criteriaItems>
            <field>Receipt__c.Receipt_Type__c</field>
            <operation>notEqual</operation>
            <value>Consolidated</value>
        </criteriaItems>
        <criteriaItems>
            <field>Receipt__c.Receipt_Name__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Receipt__c.Receipt_Street__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Receipt__c.Receipt_City__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Receipt__c.Receipt_State_Province__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Receipt__c.Receipt_Zip_Postal_Code__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Gift__c.Amount__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <description>Auto emails gift receipt when the Auto Email Receipt box is checked off.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>TransactionAcknowledged</fullName>
        <actions>
            <name>UpdateTransactionAcknowledged</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Receipt__c.Status__c</field>
            <operation>equals</operation>
            <value>Issued</value>
        </criteriaItems>
        <description>If Receipt is issued then set Transaction to acknowledged</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UpdateAmountNotEligible</fullName>
        <actions>
            <name>UpdateAmountNotEligible</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Gift__c.Sponsorship_Amount__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <description>Updates Amount Not Eligible field if Sponsorship/Benefit is inputted</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UpdateReceiptletterTxt</fullName>
        <actions>
            <name>UpdateReceiptLetterTxt2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates letter portion of acknowledgement. Field used for merging with email receipting.</description>
        <formula>NOT( ISBLANK( Gift__r.Letter__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Write Receipt Address</fullName>
        <actions>
            <name>Update_Receipt_Address</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Receipt_City</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Receipt_Country</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Receipt_State</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Receipt_Street</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Receipt_ZipCode</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Captures point in time receipt address.</description>
        <formula>NOT(ISBLANK(Gift__r.Constituent__c ))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Write Receipt Name</fullName>
        <actions>
            <name>Update_Receipt_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Captures point in time constituent name for receipt.</description>
        <formula>NOT(ISBLANK(Gift__r.Constituent__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>WriteReceiptAddress %28Org%29</fullName>
        <actions>
            <name>UpdateReceiptAddress_Org</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Receipt_City_Org</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Receipt_Country_Org</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Receipt_State_Org</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Receipt_Street_org</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Receipt_ZipCode_Org</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Writes receipt address for Organizational gifts.</description>
        <formula>NOT(ISBLANK(Gift__r.Organization__c ))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>WriteReceiptName %28Org%29</fullName>
        <actions>
            <name>UpdateReceiptName_Org</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Writes receipt name for organizational gifts.</description>
        <formula>NOT(ISBLANK(Gift__r.Organization__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <tasks>
        <fullName>Automated_Email_Receipt_Sent</fullName>
        <assignedTo>cvdevmgr@causeview.com</assignedTo>
        <assignedToType>user</assignedToType>
        <description>The system has emailed the donor their receipt.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Automated Email Receipt Sent</subject>
    </tasks>
</Workflow>
