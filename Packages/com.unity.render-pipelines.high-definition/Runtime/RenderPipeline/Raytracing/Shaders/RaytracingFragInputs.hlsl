#ifdef FRAG_INPUTS_ENABLE_STRIPPING
    #error "FragInputs stripping not supported and not needed for ray tracing"
#endif

void BuildFragInputsFromIntersection(IntersectionVertex currentVertex, out FragInputs outFragInputs)
{
    float3 rayDirection = WorldRayDirection();
    outFragInputs.positionSS = float4(0.0, 0.0, 0.0, 0.0);
    outFragInputs.positionRWS = WorldRayOrigin() + rayDirection * RayTCurrent();
    outFragInputs.texCoord0 = currentVertex.texCoord0;
    outFragInputs.texCoord1 = currentVertex.texCoord1;
    outFragInputs.texCoord2 = currentVertex.texCoord2;
    outFragInputs.texCoord3 = currentVertex.texCoord3;
    outFragInputs.color = currentVertex.color;

    // Compute the world space normal
    float3 normalWS = normalize(mul(currentVertex.normalOS, (float3x3)WorldToObject3x4()));
    float3 tangentWS = normalize(mul(currentVertex.tangentOS.xyz, (float3x3)WorldToObject3x4()));
    outFragInputs.tangentToWorld = CreateTangentToWorld(normalWS, tangentWS, sign(currentVertex.tangentOS.w));

    outFragInputs.isFrontFace = dot(rayDirection, outFragInputs.tangentToWorld[2]) < 0.0f;
}

uint GetCurrentVertexAndBuildFragInputs(AttributeData attributeData, out IntersectionVertex currentVertex, out FragInputs outFragInputs)
{
    uint currentFrameIndex = 0; //Used for VFX

    #ifdef HAVE_VFX_MODIFICATION
    ZERO_INITIALIZE(IntersectionVertex, currentVertex);
    BuildFragInputsFromVFXIntersection(attributeData, outFragInputs, currentFrameIndex);
    #else
    GetCurrentIntersectionVertex(attributeData, currentVertex);
    // Build the Frag inputs from the intersection vertice
    BuildFragInputsFromIntersection(currentVertex, outFragInputs);
    #endif

    return currentFrameIndex;
}
