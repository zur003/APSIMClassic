﻿using System;
using System.Text;
using System.Xml;
using System.Reflection;
using System.Runtime.InteropServices;
using CSGeneral;
using CMPServices;

//=========================================================================
/// <summary>
/// This class creates an instance of the Apsim Component class that is used
/// to host an Apsim .net component. TAPSIMHost descends from TBaseComp
/// which is a non system component. TBaseComp 
/// </summary>
//=========================================================================
public class TAPSIMHost : TBaseComp
{
    private int tickID;
    const int smEXECUTE = 1;

    protected ApsimComponent Comp;

    //=========================================================================
    /// <summary>
    /// Create an instance of a component here
    /// </summary>
    /// <param name="compID"></param>
    /// <param name="parentCompID"></param>
    /// <param name="messageCallback"></param>
    //=========================================================================
    public TAPSIMHost(uint compID, uint parentCompID, MessageFromLogic messageCallback,
                      String _STYPE, String _SVERSION, String _SAUTHOR)
        : base(compID, parentCompID, messageCallback, _STYPE, _SVERSION, _SAUTHOR)
    {
        //create an APSIM component here
        Assembly Assemb = Assembly.GetCallingAssembly();    //get the cmp component that uses this library
        Comp = new ApsimComponent(Assemb, (int)compID, this);

        Comp.CompClass = _STYPE;
        Comp.createInstance(Assemb.Location, compID, parentCompID);
        FModuleName = getModulePath();
    }
    //=========================================================================
    /// <summary>
    /// 
    /// </summary>
    /// <param name="iStage"></param>
    //=========================================================================
    public override void initialise(int iStage)
    {
        if (iStage == 1)
        {
            Comp.Init1Handler();   //do any APSIM related tasks
        }
        if (iStage == 2)
        {
            Comp.Init2Received = true;
            // We need a tick to determine when to write the "day = ..." heading to a summary file. 
            tickID = eventList.Count;
            addEvent("tick", tickID, TypeSpec.KIND_SUBSCRIBEDEVENT, TTimeStep.typeTIMESTEP, "", "", 0);  //subscribe "tick" event
            DefineSimpleTranistions(tickID);
            //now search for all the sibling components
            String sSearchName = FName;
            if (FName.Contains("."))
                sSearchName = FName.Substring(0, FName.LastIndexOf('.')) + ".*";
            sendQueryInfo(sSearchName, TypeSpec.KIND_COMPONENT, TypeSpec.KIND_COMPONENT);
            Comp.handleEvent(ApsimComponent.INIT2INDEX, null);
        }   
    }
    //=========================================================================
    /// <summary>
    /// A handler for returnInfo message.
    /// </summary>
    /// <param name="sReqName">Name of the entity requested.</param>
    /// <param name="sReturnName">Name of the entity returned.</param>
    /// <param name="ownerID">ID of the owning component of the entity.</param>
    /// <param name="entityID">ID of the entity found.</param>
    /// <param name="iKind">Kind of entity.</param>
    /// <param name="sDDML">DDML type of the entity.</param>
    //=========================================================================
    public override void processEntityInfo(string sReqName, string sReturnName, uint ownerID, uint entityID, int iKind, string sDDML)
    {
        base.processEntityInfo(sReqName, sReturnName, ownerID, entityID, iKind, sDDML);
        //queryInfo's have been sent for sibling component names
        if (iKind == TypeSpec.KIND_COMPONENT)
        {
            Comp.SiblingComponents.Add(entityID, sReturnName);  //add all names including itself
        }
    }
    //=========================================================================
    /// <summary>
    /// Handle the QuerySetValue message.
    /// </summary>
    /// <param name="propertyID"></param>
    /// <param name="aValue"></param>
    /// <returns></returns>
    //=========================================================================
    public override bool writeProperty(int propertyID, TTypedValue aValue)
    {
        return Comp.onQuerySetValue(propertyID, aValue);
    }
    //=========================================================================
    /// <summary>
    /// 
    /// </summary>
    /// <param name="propertyID"></param>
    /// <param name="aValue"></param>
    //=========================================================================
    public override void initProperty(int propertyID, TTypedValue aValue)
    {
        sendError("simulation: Invalid property ID in initProperty()", true);
    }
    //=========================================================================
    /// <summary>
    /// Std properties are already taken care of in the parent class.
    /// Now do a look up of the specialised component properties.
    /// Parent class then sends this value in a ReplyValue msg.
    /// </summary>
    /// <param name="propertyID"></param>
    /// <param name="requestorID"></param>
    /// <param name="aValue">Return value is stored here.</param>
    //=========================================================================
    public override void readProperty(int propertyID, uint requestorID, ref TPropertyInfo aValue)
    {
        Comp.onQueryValue(propertyID, requestorID, ref aValue);
    }
    //=========================================================================
    /// <summary>
    /// 
    /// </summary>
    /// <param name="driverID"></param>
    /// <param name="providerID"></param>
    /// <param name="aValue"></param>
    //=========================================================================
    public override void assignDriver(int driverID, uint providerID, TTypedValue aValue)
    {
        if (!Comp.assignDriver(driverID, providerID, aValue))
            base.assignDriver(driverID, providerID, aValue);
    }
    //=========================================================================
    /// <summary>
    /// 
    /// </summary>
    /// <param name="eventID"></param>
    /// <param name="iState"></param>
    /// <param name="publisherID"></param>
    /// <param name="aParams"></param>
    /// <returns></returns>
    //=========================================================================
    public override int processEventState(int eventID, int iState, uint publisherID, TTypedValue aParams)
    {
        int iCondition = 0;
        if (eventID == tickID)
        {
            //execute tick event
        }
        else {
            byte[] data = new byte[aParams.sizeBytes()];
            aParams.getData(ref data);
            Comp.handleEvent(eventID, data);
        }
        ////return base.processEventState(eventID, iState, publisherID, aParams);
        return iCondition;
    }
    //============================================================================
    /// <summary>
    /// Override the init1 so that the Apsim component can have access to the SDML script.
    /// </summary>
    /// <param name="msg"></param>
    /// <param name="SDML"></param>
    /// <param name="FQN"></param>
    //============================================================================
    protected override void doInit1(TMsgHeader msg, string SDML, string FQN)
    {
        Comp.ComponentID = msg.to;  //ensure this is set
        Comp.Name = FQN;
        Comp.setScript(SDML);
        base.doInit1(msg, SDML, FQN);
    }
    //=========================================================================
    /// <summary>
    /// 
    /// </summary>
    /// <param name="eventID"></param>
    //=========================================================================
    public void DefineSimpleTranistions(int eventID)
    {
        defineEventTransition(eventID, TStateMachine.IDLE, 0, smEXECUTE, true);   //idle -> smExecute
        defineEventState(eventID, smEXECUTE, TStateMachine.LOGIC);
        defineEventTransition(eventID, smEXECUTE, 0, TStateMachine.DONE, false);   //smExecute -> done
    }
    //============================================================================
    /// <summary>
    /// Adds an event, sets up the state transitions and registers it in the simulation.
    /// </summary>
    /// <param name="sName">Name of the item.</param>
    /// <param name="sDDML">DDML type of the item.</param>
    /// <param name="iEventID">Local ID of the item.</param>
    /// <param name="iKind">Kind of item to register.</param>
    /// <param name="destID">Optional integer ID for a destination component.
    ///	
    /// <para>If kind=<see cref="TypeSpec.KIND_PUBLISHEDEVENT">TypeSpec.KIND_PUBLISHEDEVENT</see>, identifies a component that subscribes to the event being published. 
    /// When the event is published, it must be routed to the nominated component only.</para>
    /// 
    /// <see cref="TypeSpec.KIND_SUBSCRIBEDEVENT">TypeSpec.KIND_SUBSCRIBEDEVENT</see>, destID must be zero.</para> 
    /// 
    /// <para>If destID=0, this field is ignored and routing depends upon the protocol implementation.</para>
    /// </param>
    /// <param name="toAck">Acknowledge this message 1=true.</param>
    //============================================================================
    public void registerEvent(string sName, string sDDML, int iEventID,
                         int iKind, uint destID,
                         int toAck)
    {
        addEvent(sName, iEventID, iKind, sDDML, sName, "", destID);
        DefineSimpleTranistions(iEventID);
    }
    //============================================================================
    /// <summary>
    /// Register a new driving variable
    /// </summary>
    /// <param name="sName"></param>
    /// <param name="driverID"></param>
    /// <param name="iMinConn"></param>
    /// <param name="iMaxConn"></param>
    /// <param name="sUnit"></param>
    /// <param name="bIsArray"></param>
    /// <param name="sType"></param>
    /// <param name="sShortDescr"></param>
    /// <param name="sFullDescr"></param>
    /// <param name="sourceID"></param>
    //============================================================================
    public void registerDriver(string sName, int driverID, int iMinConn, int iMaxConn,
                               string sUnit, bool bIsArray, string sType, String sShortDescr, String sFullDescr, uint sourceID)
    {
        addDriver(sName, driverID, iMinConn, iMaxConn, sUnit, bIsArray, sType, sShortDescr, sFullDescr, sourceID);
    }
    //============================================================================
    /// <summary>
    /// Deregister event
    /// </summary>
    //============================================================================
    public void delEvent(int eventID)
    {
        deleteEvent(eventID);
    }
    public void delDriver(int driverID)
    {
        deleteDriver(driverID);
    }
    public void delProp(int propID)
    {
        deleteProperty(propID);
    }
    //============================================================================
    /// <summary>
    /// Return the number of properties in the registered property list.
    /// </summary>
    /// <returns></returns>
    //============================================================================
    public int propertyCount()
    {
        return propertyList.Count;
    }
    public int driverCount()
    {
        return driverList.Count;
    }
    public int eventCount()
    {
        return eventList.Count;
    }
    //=========================================================================
    /// <summary>
    /// 
    /// </summary>
    //=========================================================================
    public void deleteInstance()
    {
        Comp.deleteInstance();
    }
    //=========================================================================
    /// <summary>
    /// 
    /// </summary>
    /// <param name="context"></param>
    /// <returns></returns>
    //=========================================================================
    public override string description(string context)
    {
        StringBuilder str = new StringBuilder("");
        try
        {
            XmlDocument Doc = new XmlDocument();
            Doc.LoadXml(context);

            // Load the assembly.
            String ExecutableFileName = XmlHelper.Attribute(Doc.DocumentElement, "executable");
            Assembly Assemb = Assembly.LoadFile(ExecutableFileName);

            XmlNode InitData = XmlHelper.Find(Doc.DocumentElement, "initdata");
            if (InitData != null)
            {
                ApsimComponent Comp = new ApsimComponent(Assemb, 0, this);
                str.Append(Comp.GetDescription(InitData));
            }
        }
        catch (Exception err)
        {
            Console.WriteLine(err.Message);
        }
        return str.ToString();
    }
    //=========================================================================
    /// <summary>
    /// Create an init script manager. 
    /// *** For Apsim: need to determine what to implement for the init script manager.
    /// </summary>
    /// <param name="sScriptName"></param>
    //=========================================================================
    public override void createInitScript(string sScriptName)
    {
        base.createInitScript(sScriptName);
    }
    //=========================================================================
    /// <summary>
    /// Deletes the script instance. 
    /// </summary>
    /// <param name="sScriptName"></param>
    //=========================================================================
    public override void deleteInitScript(string sScriptName)
    {
        base.deleteInitScript(sScriptName);
    }
    //=========================================================================
    /// <summary>
    /// Get the event ID of the named event.
    /// </summary>
    /// <param name="eventName"></param>
    /// <returns></returns>
    //=========================================================================
    public int getEventID(String eventName)
    {
        int eventID = -1;
        for (int i = 0; i < eventList.Count; i++)
        {
            if (eventList[i] != null)
            {
                if (eventList[i].Name.ToLower() == eventName.ToLower())
                    eventID = i; //indexed as in array
            }
        }
        return eventID;
    }
}

