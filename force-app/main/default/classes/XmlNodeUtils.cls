/**
 * @description This class contains utils for Apex Dom classes
 * 
 * @author Jimmy Li
 * @changelog
 * 07/12/2021 - Jimmy Li - Added
 */
public with sharing class XmlNodeUtils 
{
    /**
     * This method convert a XML node to XML String based on Dom.Document
     * @param node   : Dom.XmlNode instance - the node need to be converted as XML stirng
     */
    public static String toXmlString(Dom.XMLNode node)
    {
        Dom.Document newDocument = new Dom.Document();

        String rootNodeName = node.getName();
        String rootNodeNamespace = node.getNamespace();
        String rootNodeNamespacePrefiex = node.getPrefixFor(rootNodeNamespace);
        
        newDocument.createRootElement(rootNodeName, rootNodeNamespace, rootNodeNamespacePrefiex);
        Dom.XMLNode rootNode = this.newDocument.getRootElement();

        copyNodes(this.rootNode, node);

        return newDocument.toXmlString();
    }
    
    /** 
    * This method makes recursive calls to clone XML node including children to another
    * @param targetNode      : Dom.XMLNode instance
    * @param sourceNode      : Dom.XMLNode instance
    */ 
    private static void copyNodes(Dom.XMLNode targetNode, Dom.XMLNode sourceNode)
    {
        // copy all attributes
        for(Integer attrIndex = 0; attrIndex < sourceNode.getAttributeCount(); attrIndex += 1)
        {
            String attributeKey = sourceNode.getAttributeKeyAt(attrIndex);
            String attributeKeyNamespace = sourceNode.getAttributeKeyNsAt(attrIndex);
            String attributeName = sourceNode.getAttribute(attributeKey, attributeKeyNamespace);
            String attributeValue = sourceNode.getAttributeValue(attributeKey, attributeKeyNamespace);
            String attributeValueNamespace = sourceNode.getAttributeValueNs(attributeKey, attributeKeyNamespace);

            // set attribute based on if namespaces exists
            if(String.isNotBlank(attributeKeyNamespace) && String.isNotBlank(attributeValueNamespace))
            {
                targetNode.setAttributeNs(attributeKey, attributeValue, attributeKeyNamespace, attributeValueNamespace);
            }else
            {
                targetNode.setAttribute(attributeKey, attributeValue);
            }
        }

        // copy children
        for(Dom.XmlNode sourceChildNode : sourceNode.getChildren())
        {
            Dom.XmlNodeType nodeType = sourceChildNode.getNodeType();

            if(nodeType == Dom.XmlNodeType.ELEMENT)
            {
                copyNodes(targetNode.addChildElement(sourceChildNode.getName(), sourceChildNode.getNamespace(), sourceChildNode.getPrefixFor(sourceChildNode.getNamespace())), sourceChildNode);
            }
            else if(nodeType == Dom.XmlNodeType.COMMENT)
            {
                targetNode.addCommentNode(sourceChildNode.getText());
            }
            else{
                targetNode.addTextNode(sourceChildNode.getText());
            }
        }
    }
}
