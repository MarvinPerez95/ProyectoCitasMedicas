import pyodbc
from config import Config

def get_db_connection():
    """Establece una conexión con la base de datos SQL Server"""
    conn = pyodbc.connect(
        f'DRIVER={{ODBC Driver 17 for SQL Server}};'
        f'SERVER={Config.DB_SERVER};'
        f'DATABASE={Config.DB_NAME};'
        f'UID={Config.DB_USER};'
        f'PWD={Config.DB_PASSWORD}'
    )
    return conn

def execute_query(query, params=None, fetch=True):
    """Ejecuta una consulta SQL y devuelve los resultados si es necesario"""
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)
        
        if fetch:
            # Si es un SELECT, devolver los resultados
            columns = [column[0] for column in cursor.description]
            results = []
            for row in cursor.fetchall():
                results.append(dict(zip(columns, row)))
            return results
        else:
            # Si es un INSERT/UPDATE/DELETE, hacer commit y devolver filas afectadas
            conn.commit()
            return cursor.rowcount
    except Exception as e:
        conn.rollback()
        raise e
    finally:
        cursor.close()
        conn.close()

def execute_stored_procedure(proc_name, params=None):
    """Ejecuta un procedimiento almacenado y devuelve los resultados"""
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        if params:
            cursor.execute(f"EXEC {proc_name} {','.join(['?' for _ in params])}", params)
        else:
            cursor.execute(f"EXEC {proc_name}")
        
        # Intentar recuperar los resultados
        try:
            columns = [column[0] for column in cursor.description]
            results = []
            for row in cursor.fetchall():
                results.append(dict(zip(columns, row)))
            return results
        except:
            # Si no hay resultados, hacer commit y devolver None
            conn.commit()
            return None
    except Exception as e:
        conn.rollback()
        raise e
    finally:
        cursor.close()
        conn.close()