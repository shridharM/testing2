<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Pending_ACH_Pmt_Acknowledgement</fullName>
        <description>Pending ACH Pmt Acknowledgement</description>
        <protected>false</protected>
        <recipients>
            <field>Notification_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Giving_Power/Pending_Gift_Acknowledgement</template>
    </alerts>
    <alerts>
        <fullName>Returned_Payment</fullName>
        <ccEmails>salesforce@breakeveninc.com</ccEmails>
        <description>ACH Returned Payment Email</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Giving_Power/ACH_Gift_Returned_Notice</template>
    </alerts>
    <alerts>
        <fullName>SendPendingEmailAcknowledgement</fullName>
        <description>SendPendingEmailAcknowledgement</description>
        <protected>false</protected>
        <recipients>
            <field>Notification_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Giving_Power/Pending_Gift_Acknowledgement</template>
    </alerts>
    <fieldUpdates>
        <fullName>Blank_ACH_Pmt_Notification_Email</fullName>
        <field>Notification_Email_Address__c</field>
        <formula>Donation__r.Constituent__r.Email</formula>
        <name>Blank ACH Pmt Notification Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>GIftStatusUpdate1</fullName>
        <field>Status__c</field>
        <literalValue>Active</literalValue>
        <name>GIftStatusUpdate1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Donation__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>GiftStatusActive</fullName>
        <field>Status__c</field>
        <literalValue>Active</literalValue>
        <name>GiftStatusActive</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Donation__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>GiftStatusCompleted</fullName>
        <field>Status__c</field>
        <literalValue>Completed</literalValue>
        <name>GiftStatusCompleted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Donation__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Type_update</fullName>
        <field>Payment_Type__c</field>
        <literalValue>ACH/PAD</literalValue>
        <name>Type update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateLastPaymentUpdate</fullName>
        <description>Update toTransaction _sysLastPaymentUpdate field with Today</description>
        <field>sysLastPaymentUpdate__c</field>
        <formula>Today()</formula>
        <name>UpdateLastPaymentUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Donation__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateNextPaymentDate</fullName>
        <description>Calculates next payment date when a new payment is made towards gift.</description>
        <field>Next_Payment_Date__c</field>
        <formula>IF(NOT(ISNULL(Donation__r.Next_Payment_Date__c)), 
IF(ISPICKVAL(Donation__r.Recurring_Donation__r.Frequency__c,&quot;Monthly&quot;),(DATE((YEAR( Donation__r.Next_Payment_Date__c )+FLOOR(((MONTH(Donation__r.Next_Payment_Date__c)+ 1)-1)/12)),
MOD((MONTH(Donation__r.Next_Payment_Date__c)+1)-1,12)+1,MIN(DAY(Donation__r.Next_Payment_Date__c),CASE(MOD((MONTH(Donation__r.Next_Payment_Date__c)+ 1)-1,12)+1,9,30,4,30,6,30,11,30,2, 
IF(MOD(YEAR(Donation__r.Next_Payment_Date__c)+FLOOR(((MONTH(Donation__r.Next_Payment_Date__c)+ 1)-1)/12),4)=0,29,28),31)))), 
IF(ISPICKVAL(Donation__r.Recurring_Donation__r.Frequency__c,&quot;Quarterly&quot;),(DATE((YEAR(Donation__r.Next_Payment_Date__c)+FLOOR(((MONTH(Donation__r.Next_Payment_Date__c)+3)-1)/12)),
MOD((MONTH(Donation__r.Next_Payment_Date__c)+3)-1,12)+1,MIN(DAY(Donation__r.Next_Payment_Date__c),CASE(MOD((MONTH(Donation__r.Next_Payment_Date__c)+3)-1,12)+1,9,30,4,30,6,30,11,30,2, 
IF(MOD(YEAR(Donation__r.Next_Payment_Date__c)+FLOOR(((MONTH(Donation__r.Next_Payment_Date__c)+ 3)-1)/12),4)=0,29,28),31)))), 
IF(ISPICKVAL(Donation__r.Recurring_Donation__r.Frequency__c,&quot;Annually&quot;),(DATE((YEAR(Donation__r.Next_Payment_Date__c)+FLOOR(((MONTH(Donation__r.Next_Payment_Date__c)+12)-1)/12)),
MOD((MONTH(Donation__r.Next_Payment_Date__c)+12)-1,12)+1,DAY(Donation__r.Next_Payment_Date__c))),Today()))),IF(ISPICKVAL(Donation__r.Recurring_Donation__r.Frequency__c,&quot;Monthly&quot;),(DATE((YEAR(Donation__r.Recurring_Start_Date__c)+FLOOR(((MONTH(Donation__r.Recurring_Start_Date__c)+1)-1)/12)),
MOD((MONTH(Donation__r.Recurring_Start_Date__c)+1)-1,12)+1,MIN(DAY(Donation__r.Recurring_Start_Date__c),CASE(MOD((MONTH(Donation__r.Recurring_Start_Date__c)+1)-1,12)+1,9,30,4,30,6,30,11,30,2, 
IF(MOD(YEAR(Donation__r.Recurring_Start_Date__c)+FLOOR(((MONTH(Donation__r.Recurring_Start_Date__c)+ 1)-1)/12),4)=0,29,28),31)))), 
IF(ISPICKVAL(Donation__r.Recurring_Donation__r.Frequency__c,&quot;Quarterly&quot;),(DATE((YEAR(Donation__r.Recurring_Start_Date__c )+FLOOR(((MONTH(Donation__r.Recurring_Start_Date__c)+3)-1)/12)),
MOD((MONTH(Donation__r.Recurring_Start_Date__c)+3)-1,12)+1,MIN(DAY(Donation__r.Recurring_Start_Date__c),CASE(MOD((MONTH(Donation__r.Recurring_Start_Date__c)+3)-1,12)+1,9,30,4,30,6,30,11,30,2, 
IF(MOD(YEAR(Donation__r.Recurring_Start_Date__c)+FLOOR(((MONTH(Donation__r.Recurring_Start_Date__c)+3)-1)/12),4)=0,29,28),31)))), 
IF(ISPICKVAL(Donation__r.Recurring_Donation__r.Frequency__c,&quot;Annually&quot;),(DATE((YEAR(Donation__r.Recurring_Start_Date__c)+FLOOR(((MONTH(Donation__r.Recurring_Start_Date__c)+12)-1)/12)),
MOD((MONTH(Donation__r.Recurring_Start_Date__c)+12)-1,12)+1,MIN(DAY(Donation__r.Recurring_Start_Date__c),CASE(MOD((MONTH(Donation__r.Recurring_Start_Date__c)+12)-1,12)+1,9,30,4,30,6,30,11,30,2,28,31)))),Today()))))</formula>
        <name>UpdateNextPaymentDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Donation__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdatePaymentExternalId</fullName>
        <description>Updates External Id field</description>
        <field>External_Payment_ID__c</field>
        <formula>CC_Reference__c</formula>
        <name>UpdatePaymentExternalId</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdatePaymentRecordtypeACH</fullName>
        <description>Updates Payment recordtype to ACH/PAD</description>
        <field>RecordTypeId</field>
        <lookupValue>ACH_PAD</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>UpdatePaymentRecordtypeACH</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdatePaymentRecordtypeCC</fullName>
        <description>Updates recordtype to Credit Card</description>
        <field>RecordTypeId</field>
        <lookupValue>Credit_Card</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>UpdatePaymentRecordtypeCC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateRT_CC</fullName>
        <description>Updates payment recordtype to Credit Card.</description>
        <field>RecordTypeId</field>
        <lookupValue>Credit_Card</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>UpdateRT_CC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateRT_Refunded</fullName>
        <description>Update recordtype field to Refund.</description>
        <field>RecordTypeId</field>
        <lookupValue>Refund</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>UpdateRT_Refunded</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateRecordTypeUkDirectDebit</fullName>
        <description>Update Payment Record type to UK Direct Debit, when a payment type = &quot;UK Direct Debit&quot;</description>
        <field>RecordTypeId</field>
        <lookupValue>UK_Direct_Debit</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>UpdateRecordTypeUkDirectDebit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>WriteLastPaymentDate</fullName>
        <description>Writes last payment date with the payment date.</description>
        <field>Last_Payment_Date__c</field>
        <formula>Date__c</formula>
        <name>WriteLastPaymentDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Donation__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>ACH Gift Returned Notification</fullName>
        <actions>
            <name>Returned_Payment</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>ACH_Return</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Payment__c.Status__c</field>
            <operation>equals</operation>
            <value>ACH Return</value>
        </criteriaItems>
        <description>When a payment gets updated with a status of ACH-Returned</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send Pending ACH Pmt Acknowledgement</fullName>
        <actions>
            <name>Pending_ACH_Pmt_Acknowledgement</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Pending_ACH_Pmt_Acknowledgement_Sent</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Payment__c.Status__c</field>
            <operation>equals</operation>
            <value>Pending</value>
        </criteriaItems>
        <criteriaItems>
            <field>Payment__c.Amount__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Payment__c.Payment_Type__c</field>
            <operation>equals</operation>
            <value>ACH/PAD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Payment__c.Notification_Email_Address__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Send Pending ACH Payment Acknowledgement</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>TransactionActiveStatus</fullName>
        <actions>
            <name>GIftStatusUpdate1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Rollup of all payments with Status = Approved, Deposited, Refunded (Refer to Transaction apporved amount)</description>
        <formula>AND(Amount__c &gt; 0 ,  Amount__c &lt; Donation__r.Expected_Amount__c ,OR(ISPICKVAL( Status__c ,&quot;Approved&quot;) , ISPICKVAL( Status__c ,&quot;Deposited&quot;),ISPICKVAL( Status__c ,&quot;Refunded&quot;)), Donation__r.RecordType.Name  =  &quot;Pledge&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Payment Email</fullName>
        <actions>
            <name>Blank_ACH_Pmt_Notification_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Pmt_Notification_Email_Updated</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Payment__c.Payment_Type__c</field>
            <operation>equals</operation>
            <value>ACH/PAD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Payment__c.Status__c</field>
            <operation>equals</operation>
            <value>Pending</value>
        </criteriaItems>
        <description>Payment Notification if Blank is populated with constituent email</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UpdatePaymentDates</fullName>
        <actions>
            <name>UpdateNextPaymentDate</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>WriteLastPaymentDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Payment__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Payment__c.Amount__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Payment__c.Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <description>Updates last  and next payment dates on transaction when a new payment is created.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>UpdatePaymentExternalId</fullName>
        <actions>
            <name>UpdatePaymentExternalId</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Payment__c.External_Payment_ID__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Updates payment external Id field with the gateway reference number.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UpdatePaymentRT_CC</fullName>
        <actions>
            <name>UpdateRT_CC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Payment__c.Payment_Type__c</field>
            <operation>equals</operation>
            <value>Credit Card</value>
        </criteriaItems>
        <criteriaItems>
            <field>Payment__c.Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <description>Updates payment recordtype to Credit Card.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UpdatePaymentRT_Refund</fullName>
        <actions>
            <name>UpdateRT_Refunded</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Payment__c.Status__c</field>
            <operation>equals</operation>
            <value>Refunded</value>
        </criteriaItems>
        <criteriaItems>
            <field>Payment__c.Payment_Type__c</field>
            <operation>equals</operation>
            <value>Credit Card,ACH/PAD</value>
        </criteriaItems>
        <description>Sets Payment recordtype to Refund when payment status is Refunded.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UpdatePaymentRT_RefundACH</fullName>
        <actions>
            <name>Type_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Payment__c.Status__c</field>
            <operation>equals</operation>
            <value>Refunded</value>
        </criteriaItems>
        <criteriaItems>
            <field>Payment__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Refund</value>
        </criteriaItems>
        <criteriaItems>
            <field>Payment__c.Account_Number__c</field>
            <operation>equals</operation>
            <value>null</value>
        </criteriaItems>
        <description>Sets Payment recordtype to Refund when payment status is Refunded.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UpdatePaymentRecordtypeACH</fullName>
        <actions>
            <name>UpdatePaymentRecordtypeACH</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Payment__c.Payment_Type__c</field>
            <operation>contains</operation>
            <value>ACH,PAD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Payment__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>ACH/PAD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Payment__c.Status__c</field>
            <operation>notEqual</operation>
            <value>Refunded</value>
        </criteriaItems>
        <description>Updates the Payment recordtype to ACH/PAD it the payment type contains ACH.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UpdatePaymentRecordtypeCC</fullName>
        <actions>
            <name>UpdatePaymentRecordtypeCC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Payment__c.Payment_Type__c</field>
            <operation>equals</operation>
            <value>Credit Card</value>
        </criteriaItems>
        <criteriaItems>
            <field>Payment__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Credit Card</value>
        </criteriaItems>
        <criteriaItems>
            <field>Payment__c.Status__c</field>
            <operation>notEqual</operation>
            <value>Refunded</value>
        </criteriaItems>
        <description>Updates the Payment recordtype to Credit Card it the payment type is Credit Card.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UpdatePaymentRecordtypeUkDirectDebit</fullName>
        <actions>
            <name>UpdateRecordTypeUkDirectDebit</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Payment__c.Payment_Type__c</field>
            <operation>equals</operation>
            <value>UK Direct Debit</value>
        </criteriaItems>
        <description>Updates the Payment recordtype to Uk Direct Debit if the payment type is Uk Direct Debit.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UpdateTransactionPaymentSysDate</fullName>
        <actions>
            <name>UpdateLastPaymentUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Payment__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>If Payment has been update, then update Transaction _sysLastAllocationUpdate field to evaluate workflows.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <tasks>
        <fullName>ACH_Return</fullName>
        <assignedTo>cvdevmgr@causeview.com</assignedTo>
        <assignedToType>user</assignedToType>
        <description>ACH Payment has been returned by the bank</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>ACH Return</subject>
    </tasks>
    <tasks>
        <fullName>Pending_ACH_Pmt_Acknowledgement_Sent</fullName>
        <assignedTo>cvdevmgr@causeview.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Pending ACH Pmt Acknowledgement Sent</subject>
    </tasks>
    <tasks>
        <fullName>Pending_Pmt_Acknowledgement_Sent</fullName>
        <assignedTo>cvdevmgr@causeview.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Pending Pmt Acknowledgement Sent</subject>
    </tasks>
    <tasks>
        <fullName>Pmt_Notification_Email_Updated</fullName>
        <assignedTo>cvdevmgr@causeview.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Pmt Notification Email Updated</subject>
    </tasks>
</Workflow>
