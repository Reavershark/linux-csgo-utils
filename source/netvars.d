module netvars;

import memory;

struct Netvars
{
    void dump(Handle h, ulong clientStateAddress)
    {
        ClientClass currentClass = h.read!ClientClass(clientStateAddress);
    }
}

extern(C++)
{
    struct IClientNetworkable {};
    struct CRecvDecoder {};
    struct CRecvProxyData {};
    
    enum SendPropType
    {
        DPT_Int=0,
        DPT_Float,
        DPT_Vector,
        DPT_VectorXY,
        DPT_String,
        DPT_Array,
        DPT_DataTable,
        DPT_Int64,
        DPT_NUMSendPropTypes
    }
    
    struct RecvProp
    {
    public:
        char*               m_pVarName;
        SendPropType        m_RecvType;
        int                 m_Flags;
        int                 m_StringBufferSize;
        bool                m_bInsideArray;
        const void*         m_pExtraData;
        RecvProp*           m_pArrayProp;
        void*               m_ArrayLengthProxy;
        void*               m_ProxyFn;
        void*               m_DataTableProxyFn;
        RecvTable*          m_pDataTable;
        int                 m_Offset;
        int                 m_ElementStride;
        int                 m_nElements;
        const char*         m_pParentArrayPropName;
    };
    
    struct RecvTable
    {
    public:
        RecvProp*           m_pProps;
        int                 m_nProps;
        CRecvDecoder*       m_pDecoder;
        char*               m_pNetTableName;
        bool                m_bInitialized;
        bool                m_bInMainList;
    };
    
    struct ClientClass
    {
    public:
        void*               m_pCreateFn;
        void*               m_pCreateEventFn;
        char*               m_pNetworkName;
        RecvTable*          m_pRecvTable;
        ClientClass*        m_pNext;
        int                 m_ClassID;
    };
}
