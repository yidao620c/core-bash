DELETE FROM t_apply
WHERE id IN (
	SELECT apply_id FROM t_apply_record WHERE public_user_id IN(40, 41, 42, 43)
);

DELETE FROM t_hasten
WHERE apply_record_id IN (
	SELECT id FROM t_apply_record WHERE public_user_id IN(40, 41, 42, 43)
);

DELETE FROM t_policy
WHERE taxcode IN (
	'440100000000001', '440100000000002', '440100000000003', '440100000000004'
);

DELETE FROM t_product_card
WHERE id IN (
	SELECT A.product_id
	FROM t_appointment A LEFT OUTER JOIN t_apply_record B ON A.record_id=B.id
	WHERE public_user_id IN(40, 41, 42, 43)
);

DELETE FROM t_appointment
WHERE record_id IN (
	SELECT id FROM t_apply_record WHERE public_user_id IN(40, 41, 42, 43)
);

DELETE FROM t_personal_asset
WHERE record_id IN (
	SELECT id FROM t_apply_record WHERE public_user_id IN(40, 41, 42, 43)
);

DELETE FROM t_company_mortgage
WHERE record_id IN (
	SELECT id FROM t_apply_record WHERE public_user_id IN(40, 41, 42, 43)
);

DELETE FROM t_company_debt
WHERE record_id IN (
	SELECT id FROM t_apply_record WHERE public_user_id IN(40, 41, 42, 43)
);

DELETE FROM t_apply_record WHERE public_user_id IN(40, 41, 42, 43);


