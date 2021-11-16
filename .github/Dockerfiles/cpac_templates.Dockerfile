# Get templates from Washington University NHP Pipelines
FROM alpine/git AS Washington-University_NHPPipelines

ARG DEBIAN_FRONTEND=noninteractive

RUN git clone --branch v0.1.1 --depth 1 https://github.com/DCAN-Labs/dcan-macaque-pipeline.git && \
    cd dcan-macaque-pipeline/global/templates && \
    mkdir -p /macaque_templates && \
    for FILE in $(ls MacaqueYerkes19*mm.nii.gz MacaqueYerkes19*mm_brain.nii.gz MacaqueYerkes19*brain_mask.nii.gz); \
    do cp $FILE /macaque_templates/$FILE; \
    done && \
    for FILE in $(ls JointLabelCouncil/MacaqueYerkes19_T1w_0.5mm/); \
    do cp JointLabelCouncil/MacaqueYerkes19_T1w_0.5mm/$FILE /macaque_templates/MacaqueYerkes19_T1w_0.5mm_desc-JLC_$FILE; \
    done && \
    for FILE in $(ls JointLabelCouncil/J_Macaque_11mo_atlas_nACQ_194x252x160space_0.5mm/); \
    do cp JointLabelCouncil/J_Macaque_11mo_atlas_nACQ_194x252x160space_0.5mm/$FILE /macaque_templates/J_Macaque_11mo_atlas_nACQ_194x252x160space_0.5mm_desc-JLC_$FILE; \
    done;

# using neurodebian runtime as parent image
FROM neurodebian:bionic-non-free

ARG DEBIAN_FRONTEND=noninteractive

# create usergroup and user
RUN groupadd -r c-pac && \
    useradd -r -g c-pac c-pac_user && \
    mkdir -p /home/c-pac_user/ && \
    chown -R c-pac_user:c-pac /home/c-pac_user

# Move all templates into /cpac_templates
COPY --from=Washington-University_NHPPipelines /macaque_templates/* /cpac_templates/
ADD atlases/label/*/* /cpac_templates/

# set user
USER c-pac_user
