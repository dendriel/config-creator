USE config_creator;

CREATE TABLE `user` (
    `id` bigint NOT NULL AUTO_INCREMENT,
    `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
    `login` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
    `password` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
    `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
    `active` tinyint(1) DEFAULT '1',
    `service` tinyint(1) NOT NULL DEFAULT '0',
    PRIMARY KEY (`id`),
    UNIQUE KEY `UK_ob8kqyqqgmefl0aco34akdtpe` (`email`),
    UNIQUE KEY `UK_ew1hvam8uwaknuaellwhqchhb` (`login`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


-- root user (auth service)
INSERT INTO config_creator.user (active, email, login, name, password, service)
VALUES (true, 'root@configcreator.com', 'root', 'Root User', '$2a$10$3Q7pJfN1TaKAdG1Elwg5/OYgXUldw28.pphOhj8BZuN.R1uaI4eyi', false);

-- storage service user (auth service)
INSERT INTO config_creator.user (active, email, login, name, password, service)
VALUES (true, 'exporter.service@configcreator.com', 'exporter', 'Config Creator Exporter Service', '$2a$10$BppwD0txNhb4Jfw4n0AuSO7/4UWlmGK/9LKg9GPGINbMqB2dE8uy6', true);
