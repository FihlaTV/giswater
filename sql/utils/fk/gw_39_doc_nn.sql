--DROP
ALTER TABLE doc ALTER COLUMN "path" DROP NOT NULL;
ALTER TABLE doc ALTER COLUMN "doc_type" DROP NOT NULL;

ALTER TABLE doc_x_node ALTER COLUMN doc_id DROP NOT NULL;
ALTER TABLE doc_x_node ALTER COLUMN node_id DROP NOT NULL;

ALTER TABLE doc_x_arc ALTER COLUMN doc_id DROP NOT NULL;
ALTER TABLE doc_x_arc ALTER COLUMN arc_id DROP NOT NULL;

ALTER TABLE doc_x_connec ALTER COLUMN doc_id DROP NOT NULL;
ALTER TABLE doc_x_connec ALTER COLUMN connec_id DROP NOT NULL;

ALTER TABLE doc_x_visit ALTER COLUMN doc_id DROP NOT NULL;
ALTER TABLE doc_x_visit ALTER COLUMN visit_id DROP NOT NULL;

--CREATE
ALTER TABLE doc ALTER COLUMN "path" SET NOT NULL;
ALTER TABLE doc ALTER COLUMN "doc_type" SET NOT NULL;

ALTER TABLE doc_x_node ALTER COLUMN doc_id SET NOT NULL;
ALTER TABLE doc_x_node ALTER COLUMN node_id SET NOT NULL;

ALTER TABLE doc_x_arc ALTER COLUMN doc_id SET NOT NULL;
ALTER TABLE doc_x_arc ALTER COLUMN arc_id SET NOT NULL;

ALTER TABLE doc_x_connec ALTER COLUMN doc_id SET NOT NULL;
ALTER TABLE doc_x_connec ALTER COLUMN connec_id SET NOT NULL;

ALTER TABLE doc_x_visit ALTER COLUMN doc_id SET NOT NULL;
ALTER TABLE doc_x_visit ALTER COLUMN visit_id SET NOT NULL;


