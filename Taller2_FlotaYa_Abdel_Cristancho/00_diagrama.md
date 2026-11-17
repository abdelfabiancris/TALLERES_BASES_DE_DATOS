# Taller 2 – FlotaYa
**Estudiante:** Abdel Cristancho  
**Fecha de corte:** 2026-11-23

## Modelo ER (Mermaid)
```mermaid
erDiagram
 departments ||--o{ cities : contiene
 cities ||--o{ branches : alberga
 branches ||--o{ employees : asigna
 categories ||--o{ models : clasifica
 brands ||--o{ models : fabrica
 models ||--o{ vehicles : tiene
 categories ||--o{ seasonal_rates : tarifa
 seasons ||--o{ seasonal_rates : aplica
 vehicles ||--o{ maintenances : recibe
 workshops ||--o{ maintenances : ejecuta
 cities ||--o{ customers : residencia
 customers ||--o{ licenses : posee
 customers ||--o{ reservations : solicita
 vehicles ||--o{ reservations : reserva
 branches ||--o{ reservations : recoge
 branches ||--o{ reservations : devuelve
 reservations ||--o| contracts : convierte
 employees ||--o{ contracts : firma
 contracts ||--o| deliveries : registra
 contracts ||--o| returns : registra
 employees ||--o{ deliveries : entrega
 employees ||--o{ returns : recibe
 branches ||--o{ deliveries : sede
 branches ||--o{ returns : sede
 contracts ||--o{ inspections : inspecciona
 employees ||--o{ inspections : realiza
 inspections ||--o{ damages : detecta
 contracts ||--|| deposits : garantiza
 contracts ||--o{ payments : paga
 contracts ||--o{ contract_extras : incluye
 extras ||--o{ contract_extras : pacta
 contracts ||--o{ contract_additional_drivers : autoriza
 additional_drivers ||--o{ contract_additional_drivers : conduce

 departments { BIGINT id PK VARCHAR name UK }
 cities { BIGINT id PK BIGINT department_id FK VARCHAR name }
 branches { BIGINT id PK BIGINT city_id FK VARCHAR name UK BOOLEAN is_airport }
 employees { BIGINT id PK BIGINT branch_id FK VARCHAR email UK ENUM role }
 categories { BIGINT id PK VARCHAR name UK INT min_driver_age DECIMAL deposit_amount }
 brands { BIGINT id PK VARCHAR name UK }
 models { BIGINT id PK BIGINT brand_id FK BIGINT category_id FK ENUM transmission ENUM fuel }
 vehicles { BIGINT id PK BIGINT model_id FK BIGINT branch_id FK VARCHAR plate UK ENUM status INT mileage_km }
 seasons { BIGINT id PK VARCHAR name UK ENUM season_type DATE starts_on DATE ends_on }
 seasonal_rates { BIGINT id PK BIGINT category_id FK ENUM season_type DECIMAL daily_rate }
 workshops { BIGINT id PK VARCHAR name UK }
 maintenances { BIGINT id PK BIGINT vehicle_id FK BIGINT workshop_id FK ENUM maintenance_type DATE started_on DATE ended_on }
 customers { BIGINT id PK BIGINT city_id FK VARCHAR document_number UK ENUM status }
 licenses { BIGINT id PK BIGINT customer_id FK VARCHAR license_number UK DATE expires_on }
 additional_drivers { BIGINT id PK VARCHAR document_number UK VARCHAR license_number UK }
 reservations { BIGINT id PK BIGINT customer_id FK BIGINT vehicle_id FK BIGINT pickup_branch_id FK BIGINT return_branch_id FK DATE pickup_date DATE return_date }
 contracts { BIGINT id PK BIGINT reservation_id FK BIGINT employee_id FK DATE started_on DATE expected_end DATE actual_return }
 extras { BIGINT id PK VARCHAR name UK DECIMAL list_daily_price }
 contract_extras { BIGINT id PK BIGINT contract_id FK BIGINT extra_id FK INT quantity DECIMAL agreed_daily_price }
 contract_additional_drivers { BIGINT id PK BIGINT contract_id FK BIGINT additional_driver_id FK }
 deliveries { BIGINT id PK BIGINT contract_id FK BIGINT branch_id FK BIGINT employee_id FK DATETIME delivered_at }
 returns { BIGINT id PK BIGINT contract_id FK BIGINT branch_id FK BIGINT employee_id FK DATETIME returned_at }
 inspections { BIGINT id PK BIGINT contract_id FK ENUM stage DATETIME inspected_at }
 damages { BIGINT id PK BIGINT inspection_id FK VARCHAR description ENUM severity DECIMAL repair_cost BOOLEAN charge_customer }
 deposits { BIGINT id PK BIGINT contract_id FK DECIMAL amount DECIMAL applied_amount ENUM status }
 payments { BIGINT id PK BIGINT contract_id FK DECIMAL amount ENUM concept ENUM payment_method }
```

## Cardinalidades y decisiones
- Departamento 0..N ciudades; ciudad 1..1 departamento y 0..N sedes; sede 1..1 ciudad.
- Las reservas tienen dos relaciones distintas con `branches`: sede de recogida y sede de devolución. Entrega y devolución también guardan su sede y empleado.
- Una reserva produce 0..1 contrato; cada contrato nace de exactamente una reserva. La FK única `contracts.reservation_id` impide dos contratos por reserva.
- Contrato–extra y contrato–conductor adicional son N:M y se resuelven con tablas puente. La cantidad y el precio diario pactado pertenecen a `contract_extras`.
- Cada contrato tiene como máximo una entrega y una devolución; una inspección por etapa, garantizada con UNIQUE(contract_id, stage).
- Los daños pertenecen a una inspección, no directamente al contrato. Un daño de entrega es previo y `charge_customer=FALSE`.
- Licencias se conservan como filas históricas; el adicional es entidad independiente y no necesita ser cliente.

## Normalización
**1FN:** sería defectuoso guardar `extras="GPS, silla, seguro"` en una sola columna. Se separa en `extras` y `contract_extras`, una fila por extra y contrato.

**2FN:** en una tabla puente con clave compuesta `(contract_id, extra_id)`, cantidad y precio pactado dependen de la pareja completa, no solo del contrato o del extra.

**3FN:** sería defectuoso repetir `category_name`, edad mínima y depósito en cada vehículo. Se guardan en `categories`, y `models` referencia la categoría. Las tarifas dependen de categoría + tipo de temporada, no de la temporada nominal.

**4FN:** no hace falta una descomposición adicional: licencias, extras, conductores y daños son hechos multivaluados independientes y ya están en relaciones separadas.

## Datos calculados vs almacenados
La edad se calcula con fecha de nacimiento y fecha de referencia. La cotización inicial se almacena como fotografía comercial; la función puede recalcularla. El alquiler final se recalcula al cierre con devolución real. El saldo se calcula como cargos menos pagos, no se almacena como valor editable.

## Preguntas guía
1. Reserva y contrato no son lo mismo: la reserva puede cancelarse; el contrato nace al convertirla. El cliente se obtiene desde la reserva y no se duplica.
2. El precio pactado se conserva en `contract_extras.agreed_daily_price`, aunque cambie el catálogo.
3. Son 6 × 3 = 18 tarifas. Dependen del tipo de temporada (BAJA/MEDIA/ALTA), no del nombre de cada temporada.
4. Edad mínima y depósito pertenecen a la categoría; ponerlos en vehículo o modelo duplica reglas y causa anomalías de actualización.
5. Se dibujan roles separados de FK hacia `branches` y `employees`, por ejemplo `pickup_branch_id` y `return_branch_id`.
6. El daño pertenece a `inspections`; la etapa identifica si fue previo (ENTREGA) o encontrado al devolver (DEVOLUCION).
7. Sí: cada renovación de licencia es una fila; el conductor adicional tiene tabla propia aunque no sea cliente.
8. Se almacenan hechos y precios pactados; edad, duración, noches, alquiler final y saldo se calculan desde fechas, tarifas y pagos.

## Reglas que no protege solo el DDL
| Regla | ¿DDL? | Motivo / solución |
|---|---|---|
| 6 continuidad de temporadas | Parcial | CHECK valida rango; huecos/cruces entre filas requieren procedimiento o validación |
| 8 cálculo por noche | No | Requiere recorrer días y unir temporadas/tarifas: función |
| 9 vehículo en mantenimiento | Parcial | Fechas con CHECK; coherencia del estado del vehículo requiere procedimiento |
| 14 cruce de reservas vivas | No | Requiere comparar otras filas: `sp_crear_reserva` |
| 15 cliente/edad/licencia/vehículo | No | Requiere varias tablas y fecha: `sp_crear_reserva` |
| 20 daño previo no cobrable | Parcial | FK a inspección; la etapa requiere lógica de negocio |
| 21 depósito aplicado no mayor al retenido | Sí | CHECK en la misma fila |
| 23 cierre todo-o-nada | No | Transacción y `sp_cerrar_contrato` |
