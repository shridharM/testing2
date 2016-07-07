<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CheckDonorBox</fullName>
        <description>Checks Donor box</description>
        <field>Donor__c</field>
        <literalValue>1</literalValue>
        <name>CheckDonorBox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CheckVolunteerBox</fullName>
        <description>Sets volunteer checkbox to TRUE.</description>
        <field>Volunteer__c</field>
        <literalValue>1</literalValue>
        <name>CheckVolunteerBox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateAddressee</fullName>
        <description>Updates individual primary addressee with household value.</description>
        <field>Primary_Addressee__c</field>
        <formula>Household__r.Household_Addressee__c</formula>
        <name>UpdateAddressee</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateBlankAddressee</fullName>
        <description>Updates Primary Addressee field with default value</description>
        <field>Primary_Addressee__c</field>
        <formula>IF (ISPICKVAL(Salutation,&quot;&quot;), 
(FirstName &amp; &quot; &quot; &amp; LastName),
(TEXT(Salutation) &amp; &quot; &quot; &amp;  FirstName &amp; &quot; &quot; &amp; LastName)
)</formula>
        <name>UpdateBlankAddressee</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateBlankSalutation</fullName>
        <description>Auto populates the Salutation field with first name</description>
        <field>Primary_Salutation__c</field>
        <formula>IF (ISPICKVAL(Salutation,&quot;&quot;), 
(FirstName),
(TEXT(Salutation) &amp; &quot; &quot; &amp; LastName)
)</formula>
        <name>UpdateBlankSalutation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateHouseholdAddress</fullName>
        <description>Updates mailing address from household.</description>
        <field>MailingStreet</field>
        <formula>Household__r.BillingStreet</formula>
        <name>UpdateHouseholdAddress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateHouseholdCity</fullName>
        <description>Updates mailing city from household.</description>
        <field>MailingCity</field>
        <formula>Household__r.BillingCity</formula>
        <name>UpdateHouseholdCity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateHouseholdCountry</fullName>
        <description>Updates mailing country from household.</description>
        <field>MailingCountry</field>
        <formula>Household__r.BillingCountry</formula>
        <name>UpdateHouseholdCountry</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateHouseholdPhone</fullName>
        <description>Updates home phone from household.</description>
        <field>HomePhone</field>
        <formula>Household__r.Phone</formula>
        <name>UpdateHouseholdPhone</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateHouseholdPostal</fullName>
        <description>Updates mailing postal/zip code from household.</description>
        <field>MailingPostalCode</field>
        <formula>Household__r.BillingPostalCode</formula>
        <name>UpdateHouseholdPostal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateHouseholdState</fullName>
        <description>Updates mailing state from household.</description>
        <field>MailingState</field>
        <formula>Household__r.BillingState</formula>
        <name>UpdateHouseholdState</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateSalutation</fullName>
        <description>Updates individual primary salutation with household value.</description>
        <field>Primary_Salutation__c</field>
        <formula>Household__r.Household_Salutation__c</formula>
        <name>UpdateSalutation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UseHousehold1True</fullName>
        <description>Sets Use Household Salutation &amp; Addressee to TRUE</description>
        <field>Use_Household_Salutation_Addressee__c</field>
        <literalValue>1</literalValue>
        <name>UseHousehold1True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UseHousehold2True</fullName>
        <description>Sets Use Household Address &amp; Phone Number to TRUE</description>
        <field>Same_as_Household__c</field>
        <literalValue>1</literalValue>
        <name>UseHousehold2True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>AutoCheckHouseholdBoxes</fullName>
        <actions>
            <name>UseHousehold1True</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UseHousehold2True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Household_Primary_Contact__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>IF Head of Household then update check boxes to use Household addressee, salutation, phone and address.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Household Info</fullName>
        <actions>
            <name>UpdateHouseholdAddress</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateHouseholdCity</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateHouseholdCountry</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateHouseholdPhone</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateHouseholdPostal</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateHouseholdState</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Same_as_Household__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Updates address and phone number from Household.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>HouseholdAddresseeSalutation</fullName>
        <actions>
            <name>UpdateAddressee</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateSalutation</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Use_Household_Salutation_Addressee__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Updates contact values with household addressee and salutation.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UpdateAddressee</fullName>
        <actions>
            <name>UpdateBlankAddressee</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Primary_Addressee__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Updates Addressee field if blank.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UpdateDonorCheckbox</fullName>
        <actions>
            <name>CheckDonorBox</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Total_Lifetime_Giving__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Donor__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Updates donor checkbox if individual has given a gift</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UpdateSalutation</fullName>
        <actions>
            <name>UpdateBlankSalutation</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Primary_Salutation__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Checks to see if Primary Salutation is blank and populates default</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UpdateVolunteerFlag</fullName>
        <actions>
            <name>CheckVolunteerBox</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Volunteer_Status__c</field>
            <operation>equals</operation>
            <value>Active,In Training</value>
        </criteriaItems>
        <description>Checks volunteer box when volunteer status is Active or In Training.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
