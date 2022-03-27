//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link  "https://www.mql5.com"
#property version "1.00"
#property strict

#include <Indicators\Trend.mqh>
#include <Indicators\TimeSeries.mqh>
#include <Trade/SymbolInfo.mqh>
#include "varios.mqh"

enum ENUM_TENDENCIA
  {
   bajista,
   alcista
  };


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class C_AlertaMedia
  {

private:

   ENUM_TIMEFRAMES   i_periodo;
   ENUM_TENDENCIA    i_tendencia;

   CiMA              m_MA;

   CiLow             m_Low;
   CiHigh            m_High;
   CiTime            m_Time;

   CSymbolInfo       m_simbolo;

   double            m_precioAdicional;

   datetime          m_tiempo[2];

   void              EnviarMensaje_(
      const string mensaje1,
      const int pos
   );

public:
                     C_AlertaMedia();
                    ~C_AlertaMedia();

   ENUM_INIT_RETCODE _OnInit(

      const string _simbolo,
      const ENUM_TIMEFRAMES _periodo,

      // Media movil
      const int _MA_period, // Periodo
      const ENUM_MA_METHOD _MA_method, // Tipo

      const ENUM_TENDENCIA _tendencia, // tendencia

      const ushort _puntosAdicionales //Distancia adicional (Puntos)

   );

   void              _OnTick();

  };


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
C_AlertaMedia::C_AlertaMedia()
  {
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
C_AlertaMedia::~C_AlertaMedia()
  {
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_INIT_RETCODE C_AlertaMedia::_OnInit(

   const string _simbolo,
   const ENUM_TIMEFRAMES _periodo,

   // Media movil
   const int _MA_period, // Periodo
   const ENUM_MA_METHOD _MA_method, // Tipo

   const ENUM_TENDENCIA _tendencia, // tendencia
   const ushort _puntosAdicionales //Distancia adicional (Puntos)

)
  {

   i_periodo =  _periodo;
   i_tendencia = _tendencia;

   if(!m_simbolo.Name(_simbolo))
     {

      Print(
         "Error " +
         IntegerToString(_LastError) +
         ", simbolo " +
         m_simbolo.Name() +
         ", funcion " +
         __FUNCTION__ +
         ", linea " +
         IntegerToString(__LINE__)
      );


      return(INIT_FAILED);
     }

   if(!m_MA.Create(
         m_simbolo.Name(),
         _periodo,
         _MA_period,
         0,
         _MA_method,
         PRICE_CLOSE
      ))
     {

      Print(
         "Error " +
         IntegerToString(_LastError) +
         ", simbolo " +
         m_simbolo.Name() +
         ", funcion " +
         __FUNCTION__ +
         ", linea " +
         IntegerToString(__LINE__)
      );

      return(INIT_PARAMETERS_INCORRECT);
     }

   if(!m_Low.Create(m_simbolo.Name(), i_periodo))
     {

      Print(
         "Error " +
         IntegerToString(_LastError) +
         ", simbolo " +
         m_simbolo.Name() +
         ", funcion " +
         __FUNCTION__ +
         ", linea " +
         IntegerToString(__LINE__)
      );

      return(INIT_FAILED);
     }

   if(!m_High.Create(m_simbolo.Name(), i_periodo))
     {

      Print(
         "Error " +
         IntegerToString(_LastError) +
         ", simbolo " +
         m_simbolo.Name() +
         ", funcion " +
         __FUNCTION__ +
         ", linea " +
         IntegerToString(__LINE__)
      );

      return(INIT_FAILED);
     }

   if(!m_Time.Create(m_simbolo.Name(), i_periodo))
     {

      Print(
         "Error " +
         IntegerToString(_LastError) +
         ", simbolo " +
         m_simbolo.Name() +
         ", funcion " +
         __FUNCTION__ +
         ", linea " +
         IntegerToString(__LINE__)
      );

      return(INIT_FAILED);
     }

   m_precioAdicional = _puntosAdicionales * m_simbolo.Point();

   m_tiempo[0]=0;
   m_tiempo[1]=0;

   return(INIT_SUCCEEDED);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void C_AlertaMedia::_OnTick()
  {

   m_simbolo.RefreshRates();

   m_Time.Refresh();
   m_Low.Refresh();
   m_High.Refresh();

   m_MA.Refresh();

   string propiedadesMedia = "";
   propiedadesMedia = propiedadesMedia + EnumToString(m_MA.MaMethod());
   propiedadesMedia = propiedadesMedia + ", ";
   propiedadesMedia = propiedadesMedia + "periodo: " ;

   propiedadesMedia = propiedadesMedia +
                      IntegerToString(m_MA.MaPeriod())
                      ;

   string mensaje1 = "";

   if(i_tendencia == alcista)
     {
      mensaje1 = "Tendencia alcista \n " + propiedadesMedia;

      if((m_Low.GetData(1) - m_precioAdicional) <= m_MA.Main(1))
         EnviarMensaje_(mensaje1, 0);

      if((m_Low.GetData(2) - m_precioAdicional) <= m_MA.Main(2))
         EnviarMensaje_(mensaje1, 1);
     }

   if(i_tendencia == bajista)
     {
      mensaje1 = "Tendencia bajista \n " + propiedadesMedia;

      if((m_High.GetData(1) + m_precioAdicional) >= m_MA.Main(1))
         EnviarMensaje_(mensaje1, 0);

      if((m_High.GetData(2) + m_precioAdicional) >= m_MA.Main(2))
         EnviarMensaje_(mensaje1, 1);
     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void C_AlertaMedia::EnviarMensaje_(
   const string mensaje1,
   const int pos
)
  {

   if(m_tiempo[pos] == m_Time.GetData(pos + 1))
      return;

   const string mensaje =
      "\n" +
      m_simbolo.Name() +
      "\n" +
      mensaje1 +
      "\n"
      ;

   if(!EnviarMensaje(__FILE__, mensaje, true))
      return;

   m_tiempo[pos] = m_Time.GetData(pos + 1);
  }
//+------------------------------------------------------------------+
