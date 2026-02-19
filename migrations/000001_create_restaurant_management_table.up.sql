-- CUSTOMERS
CREATE TABLE customers (
    customer_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(25),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    no_show_count INT DEFAULT 0 CHECK (no_show_count >= 0),
    penalty_flag BOOLEAN DEFAULT FALSE
);

-- TABLES (Restaurant Tables)
CREATE TABLE tables (
    table_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    table_number VARCHAR(20) UNIQUE NOT NULL,
    capacity INT NOT NULL CHECK (capacity > 0),
    location VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE
);

-- SHIFTS
CREATE TABLE shifts (
    shift_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    shift_name VARCHAR(100),
    shift_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    CHECK (end_time > start_time)
);

-- TIME SLOTS
CREATE TABLE time_slots (
    timeslot_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    shift_id BIGINT NOT NULL,
    start_datetime TIMESTAMP NOT NULL,
    end_datetime TIMESTAMP NOT NULL,
    is_peak BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_timeslot_shift
        FOREIGN KEY (shift_id)
        REFERENCES shifts(shift_id)
        ON DELETE CASCADE,
    CHECK (end_datetime > start_datetime)
);

CREATE INDEX idx_time_slots_shift_id ON time_slots(shift_id);

-- RESERVATIONS
CREATE TABLE reservations (
    reservation_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    timeslot_id BIGINT NOT NULL,
    party_size INT NOT NULL CHECK (party_size > 0),
    status VARCHAR(50) NOT NULL CHECK (
        status IN ('confirmed', 'cancelled', 'no_show', 'completed')
    ),
    is_walk_in BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cancelled_at TIMESTAMP,
    notes TEXT,
    CONSTRAINT fk_reservation_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),
    CONSTRAINT fk_reservation_timeslot
        FOREIGN KEY (timeslot_id)
        REFERENCES time_slots(timeslot_id)
);

CREATE INDEX idx_reservations_customer_id ON reservations(customer_id);
CREATE INDEX idx_reservations_timeslot_id ON reservations(timeslot_id);


-- RESERVATION TABLE ASSIGNMENTS
CREATE TABLE reservation_table_assignments (
    reservation_id BIGINT NOT NULL,
    table_id BIGINT NOT NULL,
    PRIMARY KEY (reservation_id, table_id),
    CONSTRAINT fk_rta_reservation
        FOREIGN KEY (reservation_id)
        REFERENCES reservations(reservation_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_rta_table
        FOREIGN KEY (table_id)
        REFERENCES tables(table_id)
);

CREATE INDEX idx_rta_table_id ON reservation_table_assignments(table_id);

-- SPECIAL REQUESTS
CREATE TABLE special_requests (
    request_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    reservation_id BIGINT NOT NULL,
    request_type VARCHAR(100),
    description TEXT,
    CONSTRAINT fk_special_request_reservation
        FOREIGN KEY (reservation_id)
        REFERENCES reservations(reservation_id)
        ON DELETE CASCADE
);

CREATE INDEX idx_special_requests_reservation_id ON special_requests(reservation_id);

-- WAITSTAFF
CREATE TABLE waitstaff (
    staff_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    hire_date DATE,
    is_active BOOLEAN DEFAULT TRUE
);

-- SHIFT TABLE ASSIGNMENTS
CREATE TABLE shift_table_assignments (
    shift_id BIGINT NOT NULL,
    table_id BIGINT NOT NULL,
    staff_id BIGINT NOT NULL,
    PRIMARY KEY (shift_id, table_id),
    CONSTRAINT fk_sta_shift
        FOREIGN KEY (shift_id)
        REFERENCES shifts(shift_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_sta_table
        FOREIGN KEY (table_id)
        REFERENCES tables(table_id),
    CONSTRAINT fk_sta_staff
        FOREIGN KEY (staff_id)
        REFERENCES waitstaff(staff_id)
);
