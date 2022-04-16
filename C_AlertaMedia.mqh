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


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class C_AlertaMedia
  {

private:

   ENUM_TIMEFRAMES   i_periodo;

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

   void              EvaluarEntrada(const int index);

public:
                     C_AlertaMedia();
                    ~C_AlertaMedia();

   ENUM_INIT_RETCODE _OnInit(

      const string _simbolo,
      const ENUM_TIMEFRAMES _periodo,

      // Media movil
      const int _MA_period, // Periodo
      const ENUM_MA_METHOD _MA_method, // Tipo

      const ushort _puntosAdicionales //Distancia adicional (Puntos)

   );

   void              _OnTick();

   string            simbolo() { return m_simbolo.Name();};
   string            metodoMedia() { return EnumToString(m_MA.MaMethod());};
   int               periodoMedia() { return m_MA.MaPeriod();};
   double            valorMedia() { return m_simbolo.NormalizePrice(m_MA.Main(1));};

   string            descripcion()
     {
      return (
                m_MA.Symbol() + "   " +
                EnumToString(m_MA.Period()) + "   " +
                EnumToString(m_MA.MaMethod()) + "   " +
                IntegerToString(m_MA.MaPeriod(), 4) + "   " +
                DoubleToString(m_simbolo.NormalizePrice(m_MA.Main(1)), m_simbolo.Digits())

             );

     };

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

   const ushort _puntosAdicionales //Distancia adicional (Puntos)

)
  {

   i_periodo =  _periodo;

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

   m_tiempo[0] = 0;
   m_tiempo[1] = 0;

   return(INIT_SUCCEEDED);
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void C_AlertaMedia::EvaluarEntrada(const int index)
  {

   if(m_tiempo[index - 1] == m_Time.GetData(index))
      return;

   string mensaje = "Posible entrada en "  +
                    m_simbolo.Name() + " " +
                    EnumToString(m_MA.Period()) + "   " +
                    "indice " + IntegerToString(index) + "   " +
                    EnumToString(m_MA.MaMethod()) + "   " +
                    IntegerToString(m_MA.MaPeriod(), 4)
                    ;


   if(m_Low.GetData(index) >= m_MA.Main(index))
     {
      if((m_Low.GetData(index) - m_precioAdicional) <= m_MA.Main(index))
        {
         if(!EnviarMensaje(__FILE__, mensaje, true))
            return;
        }
     }

   if(m_High.GetData(index) <= m_MA.Main(index))
     {
      if((m_High.GetData(index) + m_precioAdicional) >= m_MA.Main(index))
        {
         if(!EnviarMensaje(__FILE__, mensaje, true))
            return;
        }
     }

   m_tiempo[index - 1] = m_Time.GetData(index);
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

   EvaluarEntrada(1);
   EvaluarEntrada(2);

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


   m_tiempo[pos] = m_Time.GetData(pos + 1);
  }
//+------------------------------------------------------------------+
