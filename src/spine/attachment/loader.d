module spine.attachment.loader;

import spine.attachment.attachment;
import spine.attachment.boundingbox;
import spine.attachment.mesh;
import spine.attachment.region;
import spine.attachment.skinnedmesh;
import spine.attachment.type;
import spine.skin.skin;

export interface AttachmentLoader {
    
    RegionAttachment newRegionAttachment(Skin skin, string name, string path);

    MeshAttachment newMeshAttachment(Skin skin, string name, string path);

    SkinnedMeshAttachment newSkinnedMeshAttachment(Skin skin, string name, string path);

    BoundingBoxAttachment newBoundingBoxAttachment(Skin skin, string name);
}