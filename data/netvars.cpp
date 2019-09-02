// SDK definitions
class IClientNetworkable;
class CRecvDecoder;
class CRecvProxyData;
class RecvProp;
class RecvTable;

typedef IClientNetworkable*	(*CreateClientClassFn)( int entnum, int serialNum );
typedef IClientNetworkable*	(*CreateEventFn)();

typedef void (*RecvVarProxyFn)( const CRecvProxyData *pData, void *pStruct, void *pOut );
typedef void (*ArrayLengthRecvProxyFn)( void *pStruct, int objectID, int currentArrayLength );
typedef void (*DataTableRecvVarProxyFn)(const RecvProp *pProp, void **pOut, void *pData, int objectID);

typedef enum
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
} SendPropType;

class RecvProp
{
public:
	char					*m_pVarName;
	SendPropType			m_RecvType;
	int						m_Flags;
	int						m_StringBufferSize;
	bool					m_bInsideArray;
	const void 				*m_pExtraData;
	RecvProp				*m_pArrayProp;
	ArrayLengthRecvProxyFn	m_ArrayLengthProxy;
	RecvVarProxyFn			m_ProxyFn;
	DataTableRecvVarProxyFn	m_DataTableProxyFn;
	RecvTable				*m_pDataTable;
	int						m_Offset;
	int						m_ElementStride;
	int						m_nElements;
	const char				*m_pParentArrayPropName;
};

class RecvTable
{
public:
	RecvProp		        *m_pProps;
	int				        m_nProps;
	CRecvDecoder	        *m_pDecoder;
	char			        *m_pNetTableName;
	bool			        m_bInitialized;
	bool			        m_bInMainList;
};

class ClientClass
{
public:
	CreateClientClassFn		m_pCreateFn;
	CreateEventFn			m_pCreateEventFn;
	char					*m_pNetworkName;
	RecvTable				*m_pRecvTable;
	ClientClass				*m_pNext;
	int						m_ClassID;
};

class ClientClassD
{
public:
	void		*m_pCreateFn;
	void			*m_pCreateEventFn;
	char					*m_pNetworkName;
	RecvTable				*m_pRecvTable;
	ClientClass				*m_pNext;
	int						m_ClassID;
};

int main(int argc, char** argv) {
  return sizeof(ClientClass);
  return sizeof(ClientClassD);
}
